# EurekaimerOS

语言：中文 | [English](README.md)

这是我的个人 NixOS 配置，核心是 **Niri**、**Noctalia**、**Home Manager** 和 **flakes**。

![](https://cdn.jsdelivr.net/gh/Eurekaimer/MyIMGs@main/img/20260417160052566.png)

## 特点

- 基于 Niri 的 Wayland 桌面工作流
- Noctalia 壳层组件
- 声明式系统和用户环境
- 可复用模块与主机专属配置分离

## 结构

```text
hosts/nixos/                 主机入口和硬件配置
home/eurekaimer/home.nix     Home Manager 入口
modules/system/              系统层模块
modules/home/                用户层模块
```

主要入口：

- `hosts/nixos/configuration.nix`
- `home/eurekaimer/home.nix`
- `modules/home/development/toolchain.nix`

## 重建

```bash
sudo nixos-rebuild switch --flake .#nixos
```

## R 和 Notebook

R 通过 Nix wrapper 提供。开发工具链包含 R Markdown、常用统计包、绘图包、Jupyter，以及声明式生成的 `R (Nix)` kernel。

重建后可以检查：

```bash
jupyter kernelspec list
```

列表里应该包含 `r-nix`。

## 备注

- `hardware-configuration.nix` 绑定具体机器，迁移时应重新生成。
- 新机器上可能需要调整 host-local 和代理相关配置。
- 当前 nixpkgs 中 `httpgd` 被标记为 broken，因此暂不启用。
