# NixOS Configuration Engineering Principles

> **Audience**: AI agents and contributors working on this repository.
> **Purpose**: Consistent, maintainable, and elegant NixOS configuration.
> **Status**: Living document — amend when patterns evolve.

---

## 1. Repository Architecture

```
/etc/nixos/
├── flake.nix              # Single entry point; thin — delegates to modules
├── flake.lock             # Pinned inputs; NEVER hand-edit
├── hosts/nixos/           # Machine-specific: hardware, local overrides
│   ├── configuration.nix  # Imports-only — zero inline config
│   └── hardware-configuration.nix
├── modules/system/        # System-wide NixOS modules
│   ├── system.nix         # Module aggregator (imports chain)
│   ├── base.nix           # Nix settings, bootloader, networking
│   ├── desktop.nix        # Display manager, DE, themes, fonts
│   ├── locale.nix         # i18n, fonts, input method
│   ├── packages.nix       # System packages
│   ├── virtualisation.nix  # libvirt/QEMU/KVM, virt-manager, SPICE USB
│   └── config/            # Static assets used by system modules
├── home/eurekaimer/       # Home-manager user config
│   └── home.nix
├── img/                   # Wallpapers and static images
├── README.md
└── SKILL.md               # This file
```

### Principles
- **`flake.nix` is a router, not a dump.** One `nixosSystem` call; all logic lives in modules.
- **`configuration.nix` imports only.** No attribute sets, no service config — just an import list.
- **One concern per module file.** `desktop.nix` for DE/greeter, `locale.nix` for i18n/fonts, etc.
- **Prefer supported declarative settings.** The login background is referenced directly by ReGreet; do not build a custom theme when a package option already covers the requirement.

---

## 2. Module Design Rules

### DO
- Use `{ pkgs, lib, inputs, ... }:` parameter destructuring
- Group related settings under one attribute path (e.g., all ReGreet config in `programs.regreet`)
- Use `mkForce`, `mkDefault`, `mkOverride` explicitly when layering
- Keep the display-manager cutover explicit: enable ReGreet/greetd and disable SDDM

### AVOID
- Inline `let ... in` for derivations longer than 15 lines — extract to a separate file or use `pkgs.callPackage`
- Duplicating package lists between system and home-manager
- `lib.mkIf` with complex conditions — prefer separate module files
- `environment.systemPackages` for user-facing GUI apps — prefer home-manager

### Greeter module template
```nix
{ pkgs, ... }:

let
  loginWallpaper = ../../img/login.png;
in
{
  programs.regreet = {
    enable = true;
    settings.background = {
      path = "${loginWallpaper}";
      fit = "Cover";
    };
    font = {
      package = pkgs.noto-fonts-cjk-sans;
      name = "Noto Sans CJK SC";
      size = 16;
    };
  };
  services.displayManager.sddm.enable = false;
}
```

---

## 3. Flake Conventions

- **Stable channel** (`nixos-25.11`) for system packages; **unstable** for fresh leaf packages
- **`inputs.X.follows`** to deduplicate nixpkgs instances — every input that transitively depends on nixpkgs MUST follow
- `specialArgs` carries `inputs` and `pkgs-unstable` to all modules
- Home-manager wired through `home-manager.nixosModules.home-manager` with `extraSpecialArgs`

---

## 4. Login Greeter

### Current pipeline
1. `programs.regreet.enable = true` enables ReGreet and greetd.
2. The Nix path `img/project_mifeng.png` becomes `background.path`.
3. Labwc hosts ReGreet as greetd's default session so GTK combo-box popovers receive normal single-click pointer events.
4. ReGreet discovers the installed Niri and Plasma desktop sessions.
5. SDDM stays explicitly disabled; do not reintroduce the old QML theme.

### Design rules
- Keep the greeter simple: background, greeting, clock, session selector, credentials.
- Use ReGreet's native `background.path` and `background.fit`; do not copy assets into a custom theme package.
- Keep the custom GTK stylesheet in `modules/system/config/regreet.css`; its twilight navy, periwinkle, and blush palette is sampled from the wallpaper.
- Use `Noto Sans CJK SC` for Chinese text.
- Configure user-visible greeter behavior in `modules/system/desktop.nix`.
- Keep the background source in `img/project_mifeng.png`.

### Rebuild workflow after greeter changes
```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos \
  --option substituters https://cache.nixos.org/
```
`nixos-rebuild switch` intentionally does not restart an active display manager. Save the graphical session, then restart the machine or run `sudo systemctl restart display-manager.service`.

---

## 5. Font Configuration

- System fonts declared in `fonts.packages` within `locale.nix`
- `fonts.fontDir.enable = true` links them into the system profile
- `fontconfig` block for rendering preferences (hinting, antialiasing, CJK fallback order)
- ReGreet receives its explicit font package and family from `programs.regreet.font`

### CJK font stack (priority order)
1. `noto-fonts-cjk-sans` — primary UI font
2. `noto-fonts-cjk-serif` — serif fallback
3. `wqy_microhei` / `wqy_zenhei` — legacy fallback
4. `sarasa-gothic` — monospace / terminal

---

## 6. Home-Manager Integration

- User config at `home/<username>/home.nix`
- `home-manager.useGlobalPkgs = true` — shares nixpkgs with system
- `home-manager.useUserPackages = true` — user packages in user profile
- GUI apps, dev tools, and dotfiles belong in home-manager, NOT `environment.systemPackages`

---

## 7. Nix Language Style

- **2-space indentation** throughout
- **Trailing commas** on multi-line lists/attrsets
- **`inherit`** for passing through variables; explicit binding otherwise
- **No `with`** in production modules — `with pkgs; [ ... ]` is acceptable only in small package lists
- **Short `let` bindings** for derivations; `rec` only when cross-references are unavoidable
- **Comments in English** (module-level) and Chinese for user-facing strings

---

## 8. Common Pitfalls

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| CJK text shows as tofu (□□□) | Greeter font lacks CJK glyphs | Set `programs.regreet.font` to `Noto Sans CJK SC` |
| Greeter changes do not appear immediately | The old display-manager process survives `nixos-rebuild switch` | Save work, then reboot or restart `display-manager.service` |
| ReGreet fails to download from USTC | Mirror NAR is missing and crates.io fallback returns 403 | Build with `--option substituters https://cache.nixos.org/` |
| Old SDDM page remains | Machine has not restarted since the greetd cutover | Verify `ExecStart`, then reboot |
| Duplicate nixpkgs in closure | Missing `inputs.X.follows` | Follow `nixpkgs` or `nixpkgs-unstable` |

---

## 9. Rebuild Checklist

Before claiming a configuration change "works":
1. `sudo nixos-rebuild switch --flake /etc/nixos#nixos --option substituters https://cache.nixos.org/` completes without error
2. `systemctl show greetd.service -p ExecStart` points to `greetd`
3. `/etc/greetd/regreet.toml` points to the intended background image
4. After saving the graphical session, reboot or restart `display-manager.service`
5. Verify `journalctl -b -u greetd.service` and visually confirm the background and CJK glyphs


---

## 10. Virtualisation And Meeting Apps

- Keep host-wide virtual machine support in `modules/system/virtualisation.nix`.
- For Windows guests, enable libvirt/QEMU/KVM, `programs.virt-manager`, swtpm, and SPICE USB redirection; keep the user in both `libvirtd` and `kvm`.
- Keep user-facing communication apps in `modules/home/applications/communication.nix`; Zoom uses stable `pkgs.zoom-us`.
- Do not set removed OVMF submodule options. Current nixpkgs exposes QEMU OVMF firmware by default through libvirt.
- If the mirror lacks `cloud-hypervisor` binaries and rebuild falls back to crates.io, disable `systemd.services.virtchd`; QEMU/libvirt Windows VMs do not need virtchd.

### Reusable prompt: Windows VM support

```text
帮我在 EurekaimerOS 里启用 QEMU/KVM/libvirt/virt-manager，用来跑 Windows 虚拟机。按现有分层修改：虚拟化服务放到 modules/system/virtualisation.nix，用户组放到 modules/system/users.nix。需要支持 Windows 11 的 TPM、USB 重定向、virt-viewer 和 virtio-win。完成后验证 flake 配置能 dry-build。
```

### Reusable prompt: meeting apps

```text
帮我按现有分层安装会议软件。Zoom 用 modules/home/applications/communication.nix 里的 pkgs.zoom-us。完成后更新 README、层次图和 SKILL。
```

### Mandatory post-work sync question

After finishing work in this repository, ask the owner:

```text
要不要我把这次改动同步到 GitHub 的 EurekaimerOS 文件夹？
```

Never write sudo passwords, tokens, or other credentials into `SKILL.md`, README files, maps, or Nix configuration.