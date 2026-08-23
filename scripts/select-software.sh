#!/usr/bin/env bash
set -euo pipefail

# Generate the host-local software selection consumed by flake.nix.  This
# script changes declarations only; Nix remains responsible for installing and
# removing packages during the next rebuild.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/.." && pwd -P)"
default_output="$repo_root/hosts/nixos/software-selection.nix"
output=$default_output
mode="interactive"
language=""
rebuild_action="ask"

usage() {
  cat <<'EOF'
Usage: select-software.sh [--all | --minimal] [--language zh|en]
                          [--output PATH] [--rebuild none|build|switch]

  no preset    Ask about each existing software category interactively.
  --all        Enable every category and personal module.
  --minimal    Keep the Niri desktop, browser, file manager, and basic CLI.
  --language   Skip the language prompt and use Chinese (zh) or English (en).
  --output     Write to PATH instead of hosts/nixos/software-selection.nix.
  --rebuild    After writing, skip rebuild, build only, or build and switch.

The generated file is declarative. Apply it with nixos-rebuild; the script
does not call nix-env or mutate the current Nix profile.
EOF
}

while (( $# > 0 )); do
  case "$1" in
    --all|--minimal)
      [[ "$mode" == interactive ]] || {
        echo "Only one preset may be supplied." >&2
        exit 2
      }
      mode="${1#--}"
      shift
      ;;
    --output)
      [[ $# -ge 2 ]] || {
        echo "--output requires a path." >&2
        exit 2
      }
      output=$2
      shift 2
      ;;
    --language)
      [[ $# -ge 2 && ( "$2" == zh || "$2" == en ) ]] || {
        echo "--language must be zh or en." >&2
        exit 2
      }
      language=$2
      shift 2
      ;;
    --rebuild)
      [[ $# -ge 2 && ( "$2" == none || "$2" == build || "$2" == switch ) ]] || {
        echo "--rebuild must be none, build, or switch." >&2
        exit 2
      }
      rebuild_action=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

# Normalize once so an explicitly supplied relative path can still be compared
# with the default path before an optional rebuild.
output="$(realpath -m -- "$output")"

choose_language() {
  [[ -n "$language" ]] && return

  printf '%s\n' \
    '请选择界面语言 / Choose interface language:' \
    '  1) 中文' \
    '  2) English'

  while true; do
    read -r -p '> ' reply
    case "$reply" in
      1|zh|ZH|中文) language=zh; return ;;
      2|en|EN|English|english) language=en; return ;;
      *) echo '请输入 1 或 2 / Enter 1 or 2.' ;;
    esac
  done
}

message() {
  local chinese=$1
  local english=$2
  if [[ "$language" == zh ]]; then
    printf '%b' "$chinese"
  else
    printf '%b' "$english"
  fi
}

heading() {
  printf '\n== %s ==\n' "$(message "$1" "$2")"
}

set_all() {
  power_tlp=true
  power_adaptive_policy=true
  power_thermal=true
  power_sleep=true
  power_diagnostics=true
  system_mounts=true
  system_gaming=true
  package_base_cli=true
  package_network=true
  package_monitoring=true
  package_archive=true
  package_dos=true
  desktop_printing=true
  desktop_bluetooth=true
  docker=true
  virtual_machines=true

  core_shell=true
  core_kitty=true
  core_fastfetch=true
  core_ui=true
  core_yazi=true
  core_trash_cleanup=true

  app_knowledge=true
  app_documents=true
  app_media=true
  app_web=true
  app_file_manager=true
  app_transfer=true
  app_communication=true

  dev_neovim=true
  dev_editors=true
  dev_cli=true
  dev_shell=true
  dev_nix=true
  dev_lua=true
  dev_markdown=true
  dev_python=true
  dev_javascript=true
  dev_java=true
  dev_go=true
  dev_rust=true
  dev_cpp=true
  dev_latex=true

  personal_lexigraph=true
  personal_komari_call=true
  personal_campus_login=true
  personal_docker_ass=true
  personal_hot100_assistant=true
}

set_minimal() {
  set_all

  power_tlp=false
  power_adaptive_policy=false
  power_thermal=false
  power_sleep=false
  power_diagnostics=false
  system_mounts=false
  system_gaming=false
  package_archive=false
  package_dos=false
  desktop_printing=false
  desktop_bluetooth=false
  docker=false
  virtual_machines=false

  core_trash_cleanup=false

  app_knowledge=false
  app_documents=false
  app_media=false
  app_transfer=false
  app_communication=false

  dev_neovim=false
  dev_editors=false
  dev_shell=false
  dev_lua=false
  dev_markdown=false
  dev_python=false
  dev_javascript=false
  dev_java=false
  dev_go=false
  dev_rust=false
  dev_cpp=false
  dev_latex=false

  personal_lexigraph=false
  personal_komari_call=false
  personal_campus_login=false
  personal_docker_ass=false
  personal_hot100_assistant=false
}

ask() {
  local variable=$1
  local chinese_prompt=$2
  local english_prompt=$3
  local default=${4:-true}
  local hint reply

  if [[ "$default" == true ]]; then
    hint="Y/n"
  else
    hint="y/N"
  fi

  while true; do
    read -r -p "$(message "$chinese_prompt" "$english_prompt") [$hint] " reply
    case "$reply" in
      "") printf -v "$variable" '%s' "$default"; return ;;
      y|Y|yes|YES) printf -v "$variable" '%s' true; return ;;
      n|N|no|NO) printf -v "$variable" '%s' false; return ;;
      *) message '请输入 y 或 n。\n' 'Please answer y or n.\n' ;;
    esac
  done
}

set_all

if [[ "$mode" == minimal ]]; then
  set_minimal
elif [[ "$mode" == interactive ]]; then
  choose_language
  printf '\n%s\n%s\n' \
    "$(message 'EurekaimerOS 软件选择向导' 'EurekaimerOS software selection')" \
    "$(message '当前完整配置是默认选择；直接按 Enter 即保留该项。' 'The current full configuration is the default; press Enter to keep an item.')"

  heading '第 1 步：系统与服务' 'Step 1: System and services'
  ask power_tlp 'TLP 设备与 CPU 基础电源策略' 'TLP baseline device and CPU policy'
  ask power_adaptive_policy '自适应六小时功耗控制器' 'Adaptive six-hour power controller'
  ask power_thermal 'thermald 温控服务' 'thermald thermal service'
  ask power_sleep '深度睡眠、合盖与休眠策略' 'Deep sleep, lid, and hibernation policy'
  ask power_diagnostics 'Powertop 电源诊断工具' 'Powertop diagnostics'
  ask system_mounts '本机数据盘挂载' 'Host-specific data-disk mounts'
  ask system_gaming '游戏环境（Steam、Wine、Lutris）' 'Gaming (Steam, Wine, Lutris)'
  ask desktop_printing '打印服务' 'Printing service'
  ask desktop_bluetooth '蓝牙' 'Bluetooth'
  ask docker 'Docker 容器' 'Docker containers'
  ask virtual_machines 'QEMU/libvirt 虚拟机' 'QEMU/libvirt virtual machines'

  heading '第 2 步：系统软件包分类' 'Step 2: System package groups'
  ask package_base_cli '基础 CLI（git、gh、Python）' 'Basic CLI (git, gh, Python)'
  ask package_network '网络工具与 mihomo' 'Network tools and mihomo'
  ask package_monitoring '系统监控工具' 'Monitoring tools'
  ask package_archive '图形压缩工具' 'Archive GUI'
  ask package_dos 'DOSBox' 'DOSBox'

  heading '第 3 步：用户核心环境' 'Step 3: Home core'
  ask core_shell 'Zsh 辅助与 shell 工具' 'Zsh helpers and shell tools'
  ask core_kitty 'Kitty 终端' 'Kitty terminal'
  ask core_fastfetch 'Fastfetch 系统信息' 'Fastfetch system information'
  ask core_ui 'GTK 主题、图标与用户目录' 'GTK theme, icons, and user directories'
  ask core_yazi 'Yazi 文件管理器' 'Yazi file manager'
  ask core_trash_cleanup '自动清理回收站' 'Automatic trash cleanup'

  heading '第 4 步：图形应用' 'Step 4: Applications'
  ask app_knowledge '知识管理（Obsidian、Zotero）' 'Knowledge tools (Obsidian, Zotero)'
  ask app_documents 'PDF 与电子书工具' 'PDF and ebook tools'
  ask app_media '媒体工具（OBS、mpv、FFmpeg）' 'Media tools (OBS, mpv, FFmpeg)'
  ask app_web '浏览器与代理界面' 'Browsers and proxy clients'
  ask app_file_manager 'PCManFM 图形文件管理器' 'PCManFM file manager'
  ask app_transfer '下载与图床（qBittorrent、PicGo）' 'Transfers (qBittorrent, PicGo)'
  ask app_communication '通信软件（飞书、QQ、微信、Zoom）' 'Communication (Feishu, QQ, WeChat, Zoom)'

  heading '第 5 步：编辑器与开发语言' 'Step 5: Editors and languages'
  ask dev_neovim 'Neovim 与插件' 'Neovim and plugins'
  ask dev_editors 'VSCode、扩展与 GitHub Desktop' 'VSCode, extensions, and GitHub Desktop'
  ask dev_cli '通用开发 CLI' 'Common development CLI'
  ask dev_shell 'Shell / Bash 工具' 'Shell / Bash tools'
  ask dev_nix 'Nix 工具' 'Nix tools'
  ask dev_lua 'Lua 工具' 'Lua tools'
  ask dev_markdown 'Markdown 工具' 'Markdown tools'
  ask dev_python 'Python 工具' 'Python tools'
  ask dev_javascript '通用 JavaScript（Node.js、pnpm）' 'General JavaScript (Node.js, pnpm)'
  ask dev_java 'Java 工具' 'Java tools'
  ask dev_go 'Go 工具' 'Go tools'
  ask dev_rust 'Rust 工具' 'Rust tools'
  ask dev_cpp 'C/C++ 工具' 'C/C++ tools'
  ask dev_latex 'LaTeX 工具' 'LaTeX tools'

  heading '第 6 步：个人专用模块' 'Step 6: Personal modules'
  ask personal_lexigraph 'Lexigraph 单词工具' 'Lexigraph vocabulary tool'
  ask personal_komari_call 'Komari Call 终端聊天工具' 'Komari Call terminal client'
  ask personal_campus_login '南开校园网 campus-login' 'Nankai campus-login'
  ask personal_docker_ass 'docker-ass 媒体服务助手' 'docker-ass media-stack helper'
  ask personal_hot100_assistant 'Hot100 Assistant VSCode 扩展' 'Hot100 Assistant VSCode extension'
fi

# Preset mode is non-interactive unless a language was supplied explicitly.
[[ -n "$language" ]] || language=en

# Resolve the only cross-category requirements before writing the selection.
if [[ "$personal_campus_login" == true && "$app_web" != true ]]; then
  message \
    'campus-login 需要 Chrome，已自动启用浏览器分类。\n' \
    'Enabling the web group because campus-login requires Chrome.\n'
  app_web=true
fi
if [[ "$personal_docker_ass" == true && "$docker" != true ]]; then
  message \
    'docker-ass 依赖 Docker，已自动启用 Docker。\n' \
    'Enabling Docker because docker-ass requires it.\n'
  docker=true
fi
if [[ "$power_adaptive_policy" == true && "$power_tlp" != true ]]; then
  message \
    '自适应功耗控制器依赖 TLP，已自动启用 TLP。\n' \
    'Enabling TLP because the adaptive power controller requires it.\n'
  power_tlp=true
fi
if [[ "$personal_hot100_assistant" == true && "$dev_editors" != true ]]; then
  message \
    'Hot100 Assistant 依赖 VSCode，已自动启用编辑器分类。\n' \
    'Enabling the editor group because Hot100 Assistant requires VSCode.\n'
  dev_editors=true
fi

output_dir="$(dirname -- "$output")"
mkdir -p "$output_dir"
tmp_file="$(mktemp "$output_dir/.software-selection.XXXXXX")"
trap 'rm -f -- "$tmp_file"' EXIT

cat > "$tmp_file" <<EOF
# Generated by scripts/select-software.sh.
# Re-run the script or edit these booleans directly; both workflows are valid.
{
  system = {
    power = {
      tlp = $power_tlp;
      adaptivePolicy = $power_adaptive_policy;
      thermal = $power_thermal;
      sleep = $power_sleep;
      diagnostics = $power_diagnostics;
    };
    mounts = $system_mounts;
    gaming = $system_gaming;

    packages = {
      baseCli = $package_base_cli;
      network = $package_network;
      monitoring = $package_monitoring;
      archive = $package_archive;
      dos = $package_dos;
    };

    desktop = {
      printing = $desktop_printing;
      bluetooth = $desktop_bluetooth;
    };

    virtualisation = {
      docker = $docker;
      virtualMachines = $virtual_machines;
    };
  };

  home = {
    core = {
      shell = $core_shell;
      kitty = $core_kitty;
      fastfetch = $core_fastfetch;
      ui = $core_ui;
      yazi = $core_yazi;
      trashCleanup = $core_trash_cleanup;
    };

    applications = {
      knowledge = $app_knowledge;
      documents = $app_documents;
      media = $app_media;
      web = $app_web;
      fileManager = $app_file_manager;
      transfer = $app_transfer;
      communication = $app_communication;
    };

    development = {
      neovim = $dev_neovim;
      editors = $dev_editors;
      cli = $dev_cli;
      shell = $dev_shell;
      nix = $dev_nix;
      lua = $dev_lua;
      markdown = $dev_markdown;
      python = $dev_python;
      javascript = $dev_javascript;
      java = $dev_java;
      go = $dev_go;
      rust = $dev_rust;
      cpp = $dev_cpp;
      latex = $dev_latex;
    };
  };

  personal = {
    lexigraph = $personal_lexigraph;
    komariCall = $personal_komari_call;
    campusLogin = $personal_campus_login;
    dockerAss = $personal_docker_ass;
    hot100Assistant = $personal_hot100_assistant;
  };
}
EOF

if command -v nix-instantiate >/dev/null 2>&1; then
  nix-instantiate --parse "$tmp_file" >/dev/null
fi

if [[ -e "$output" ]]; then
  backup="$output.backup-$(date +%Y%m%d-%H%M%S)"
  cp -a -- "$output" "$backup"
  printf '%s: %s\n' "$(message '旧配置备份' 'Previous selection')" "$backup"
fi

mv -- "$tmp_file" "$output"
trap - EXIT

printf '\n%s: %s\n' \
  "$(message '软件选择已写入' 'Software selection written to')" "$output"

choose_rebuild_action() {
  [[ "$rebuild_action" != ask ]] && return

  printf '\n%s\n' "$(message '下一步操作：' 'Next action:')"
  printf '%s\n' \
    "$(message '  1) 只生成配置，不运行 rebuild' '  1) Generate the file only')" \
    "$(message '  2) 运行 nixos-rebuild build（构建但不切换）' '  2) Run nixos-rebuild build (do not switch)')" \
    "$(message '  3) 运行 nixos-rebuild switch（构建并切换）' '  3) Run nixos-rebuild switch (build and activate)')"

  while true; do
    read -r -p '> ' reply
    case "$reply" in
      1|none) rebuild_action=none; return ;;
      2|build) rebuild_action=build; return ;;
      3|switch) rebuild_action=switch; return ;;
      *) message '请输入 1、2 或 3。\n' 'Enter 1, 2, or 3.\n' ;;
    esac
  done
}

# Presets are suitable for automation, so they do not unexpectedly prompt or
# invoke sudo.  Pass --rebuild explicitly when using --all or --minimal.
if [[ "$mode" != interactive && "$rebuild_action" == ask ]]; then
  rebuild_action=none
fi
choose_rebuild_action

if [[ "$rebuild_action" != none && "$output" != "$default_output" ]]; then
  message \
    '错误：自定义 --output 文件不会被当前 flake 读取，不能据此 rebuild。\n' \
    'Error: a custom --output file is not consumed by this flake and cannot be rebuilt.\n'
  exit 2
fi

case "$rebuild_action" in
  none)
    printf '%s\n' \
      "$(message '验证命令：nix flake check' 'Validate with: nix flake check')" \
      "$(message '应用命令：sudo nixos-rebuild switch --flake .#nixos' 'Apply with: sudo nixos-rebuild switch --flake .#nixos')"
    ;;
  build|switch)
    message '正在运行 flake 检查……\n' 'Running flake validation...\n'
    nix flake check "$repo_root"
    message '正在运行系统重建……\n' 'Running the system rebuild...\n'
    sudo nixos-rebuild "$rebuild_action" --flake "$repo_root#nixos"
    ;;
esac
