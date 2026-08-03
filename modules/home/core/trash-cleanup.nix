{ pkgs, ... }:

let
  trashCleanup = pkgs.writeShellApplication {
    name = "trash-cleanup";
    runtimeInputs = [ pkgs.python3 ];

    text = ''
      set -euo pipefail

      exec python3 - <<'PY'
      from __future__ import annotations

      import os
      import shutil
      from dataclasses import dataclass
      from datetime import datetime, timedelta
      from pathlib import Path

      LIMIT_BYTES = 10 * 1024 * 1024 * 1024
      MAX_AGE = timedelta(days=30)


      @dataclass
      class TrashEntry:
          name: str
          target: Path
          info: Path
          deleted_at: datetime
          size: int


      def trash_root() -> Path:
          xdg_data_home = os.environ.get("XDG_DATA_HOME")
          if xdg_data_home:
              return Path(xdg_data_home).expanduser() / "Trash"
          return Path.home() / ".local/share/Trash"


      def parse_deleted_at(info_path: Path) -> datetime | None:
          try:
              for line in info_path.read_text(encoding="utf-8", errors="replace").splitlines():
                  if line.startswith("DeletionDate="):
                      value = line.split("=", 1)[1].strip()
                      return datetime.strptime(value, "%Y-%m-%dT%H:%M:%S")
          except OSError:
              return None
          except ValueError:
              return None
          return None


      def path_size(path: Path) -> int:
          try:
              st = path.lstat()
          except FileNotFoundError:
              return 0

          if not path.is_dir() or path.is_symlink():
              return st.st_size

          total = st.st_size
          stack = [path]
          while stack:
              current = stack.pop()
              try:
                  with os.scandir(current) as entries:
                      for entry in entries:
                          try:
                              entry_stat = entry.stat(follow_symlinks=False)
                          except FileNotFoundError:
                              continue
                          total += entry_stat.st_size
                          if entry.is_dir(follow_symlinks=False):
                              stack.append(Path(entry.path))
              except (FileNotFoundError, PermissionError):
                  continue
          return total


      def remove_entry(entry: TrashEntry) -> None:
          if entry.target.exists() or entry.target.is_symlink():
              if entry.target.is_dir() and not entry.target.is_symlink():
                  shutil.rmtree(entry.target)
              else:
                  entry.target.unlink()
          entry.info.unlink(missing_ok=True)


      def collect_entries(root: Path) -> list[TrashEntry]:
          files_dir = root / "files"
          info_dir = root / "info"
          if not files_dir.exists() or not info_dir.exists():
              return []

          entries: list[TrashEntry] = []
          for info in info_dir.glob("*.trashinfo"):
              name = info.name.removesuffix(".trashinfo")
              target = files_dir / name

              if not target.exists() and not target.is_symlink():
                  info.unlink(missing_ok=True)
                  continue

              deleted_at = parse_deleted_at(info)
              if deleted_at is None:
                  try:
                      deleted_at = datetime.fromtimestamp(info.stat().st_mtime)
                  except FileNotFoundError:
                      continue

              entries.append(
                  TrashEntry(
                      name=name,
                      target=target,
                      info=info,
                      deleted_at=deleted_at,
                      size=path_size(target),
                  )
              )
          return entries


      def main() -> None:
          root = trash_root()
          entries = collect_entries(root)
          if not entries:
              print(f"trash-cleanup: no trash entries in {root}")
              return

          now = datetime.now()
          removed_count = 0
          removed_bytes = 0
          kept: list[TrashEntry] = []

          for entry in entries:
              if now - entry.deleted_at >= MAX_AGE:
                  remove_entry(entry)
                  removed_count += 1
                  removed_bytes += entry.size
              else:
                  kept.append(entry)

          total = sum(entry.size for entry in kept)
          if total > LIMIT_BYTES:
              for entry in sorted(kept, key=lambda item: item.deleted_at):
                  if total <= LIMIT_BYTES:
                      break
                  remove_entry(entry)
                  total -= entry.size
                  removed_count += 1
                  removed_bytes += entry.size

          print(
              "trash-cleanup: "
              f"removed={removed_count} "
              f"freed={removed_bytes}B "
              f"remaining={max(total, 0)}B "
              f"limit={LIMIT_BYTES}B "
              f"root={root}"
          )


      if __name__ == "__main__":
          main()
      PY
    '';
  };
in
{
  eureka.software.home = [ trashCleanup ];

  systemd.user.services.trash-cleanup = {
    Unit = {
      Description = "Clean old and oversized trash entries";
      Documentation = [ "man:systemd.timer(5)" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${trashCleanup}/bin/trash-cleanup";
      Nice = 10;
      IOSchedulingClass = "idle";
    };
  };

  systemd.user.timers.trash-cleanup = {
    Unit.Description = "Run trash cleanup periodically";

    Timer = {
      OnBootSec = "10m";
      OnUnitActiveSec = "6h";
      RandomizedDelaySec = "15m";
      Persistent = true;
    };

    Install.WantedBy = [ "timers.target" ];
  };
}
