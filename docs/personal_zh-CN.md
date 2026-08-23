# 个人专用模块

个人模块保存与仓库维护者的项目、学校或目录约定紧密相关的功能。它们仍使用原有 `modules/system` 与 `modules/home` 分类，只是不再混入通用应用和 shell 模块。

## 系统层入口

[`modules/system/personal.nix`](../modules/system/personal.nix) 根据 `softwareSelection.personal` 选择性导入：

- `lexigraph`：Lexigraph 的 NixOS 模块。
- `komariCall`：Komari Call 的 NixOS 模块。

两个项目仍由 `flake.nix` 固定输入版本，但关闭选择后不会再把对应 NixOS 模块接入当前系统配置。

Komari Call 进入 TUI 后可使用 `/login`、`/login deepseek` 或 `/login opencode-go`；凭据验证成功后写入系统 Keyring。切换到 OpenCode Go 套餐可运行：

```bash
komari-call config --provider opencode-go --model deepseek-v4-flash
komari-call models --provider opencode-go
```

Lexigraph 的具体程序行为由其独立 flake 模块维护；本仓库只决定是否接入，不复制其包实现和配置选项。

## Home Manager 入口

[`modules/home/personal.nix`](../modules/home/personal.nix) 聚合：

- [`personal/campus-login.nix`](../modules/home/personal/campus-login.nix)
  - 面向南开大学校园认证页。
  - 清空代理变量并使用隔离的临时 Chrome profile。
  - 依赖浏览器应用分类；选择器会自动处理，模块也提供 assertion 防止手工配置失配。
- [`personal/docker-ass.nix`](../modules/home/personal/docker-ass.nix)
  - 管理个人 ANI-RSS/qBittorrent Compose 项目。
  - 默认目录保持 `/home/eurekaimer/Videos/ASS`，可用 `DOCKER_ASS_PROJECT_DIRECTORY` 覆盖。
  - 依赖系统 Docker；选择器自动处理，模块也提供 assertion。
- `personal.hot100Assistant`
  - 控制 `development/toolchain/editors.nix` 中维护者自己的 Hot100 Assistant VSCode 扩展。
  - 依赖 VSCode 编辑器分类；扩展与其他语言扩展共用逐扩展种子机制，但不混入通用基础扩展。

Oh My Pi 是维护者要求的强制功能，不列入个人开关；它与固定 Bun 版本共同位于 `development/toolchain/oh-my-pi.nix`。

新增个人功能时，系统服务放入 `modules/system/personal/` 或由 `personal.nix` 导入外部模块；用户命令放入 `modules/home/personal/`。不要把学校 URL、私人目录或个人项目重新写回通用 `applications`、`core` 或 `development` 模块。

[English](personal.md)
