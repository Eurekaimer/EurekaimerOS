# EurekaimerOS

语言：中文 | [English (README.md)](README.md)

这是我的个人 NixOS 配置仓库，核心主线是 **Niri + Noctalia**：

![](https://cdn.jsdelivr.net/gh/Eurekaimer/MyIMGs@main/img/20260417160052566.png)

- **Niri**：负责窗口管理与日常操作流（当前主力桌面体验）。
- **Noctalia**：负责壳层交互体验（状态栏/控制中心这一类能力）。
- **Flake + Home Manager**：保证配置可声明、可复现、可迁移。

如果你也想搭一套“结构清晰、以 Niri/Noctalia 为中心”的 NixOS 配置，这个仓库就是按这个目标整理的。

## 快速恢复当前配置（先加镜像，再安装）

如果目标是尽快把当前这套配置恢复回来，推荐把早期流程压到最简单：

1. 在 Live ISO 里先给 `/etc/nix/nix.conf` 增加 Nix 镜像源
2. 用图形安装器或你习惯的 NixOS 安装流程完成基础系统安装
3. 首次进入新系统后，再给已安装系统的 `/etc/nix/nix.conf` 增加同样的镜像源
4. 恢复网络、浏览器和 GitHub 访问能力
5. 拿到完整配置仓库后执行 `sudo nixos-rebuild switch --flake .#nixos`

这样做的重点很朴素：**先让 Nix 下载走镜像，然后安装即可**。不要在系统还没装好时，把成功率绑到某个代理 GUI、浏览器登录状态或完整桌面渲染环境上。

当前镜像设置：

- 仓库内默认写入的 Nix 二进制缓存镜像：`https://mirrors.ustc.edu.cn/nix-channels/store`
- Nix 官方回退：`https://cache.nixos.org/`

说明：仓库本身在 `modules/system/base.nix` 中默认使用的是 USTC；如果你实测 SJTU 或其他镜像更稳，可以在临时安装阶段按实际情况替换。

### 第 0 步：先改 `/etc/nix/nix.conf`

在 Live ISO 阶段先把 Nix 下载源切到镜像，再继续安装。

推荐做法：

```bash
sudo cp /etc/nix/nix.conf /etc/nix/nix.conf.bak
sudo nano /etc/nix/nix.conf
```

加入这一行：

```conf
substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/
```

保存后让配置生效：

```bash
sudo systemctl restart nix-daemon
```

这样做的目的，是在正式安装前就先把 Live ISO 环境里的 Nix 下载源切到国内镜像。

### 第 1 步：先用图形界面分区

如果你本来就更习惯图形化界面，这一阶段完全可以继续用图形方式处理。

一个很朴素、通常也够用的方案是：

- 交换分区：大约 `16G` 或 `32G`，按内存大小调整，类型选 `Linux swap`
- 引导分区：大约 `2G`，`FAT32`，挂载到 `/boot`
- 剩余空间：作为根分区，挂载到 `/`

这不是唯一方案，但对单盘个人机器来说通常已经足够直接。

### 第 2 步：安装基础系统

这里推荐的默认路线就是：

- 用图形版 NixOS ISO 启动
- 连接好网络
- 在 Live ISO 里先改好 `/etc/nix/nix.conf`
- 用图形安装器或你熟悉的安装流程完成基础系统安装

图形安装器本身可以尽量按最直观的方式理解，基本就是这条线：

1. 选择语言、时区、键盘布局
2. 进入分区页面后选择手动分区
3. 按上面的 `swap / boot / root` 思路挂载
4. 填写用户名、密码、主机名
5. 检查摘要页
6. 点击安装并等待完成
7. 重启进入新系统

这一段完全可以按图形界面一步步点过去，不需要在这时引入 flake 终端安装那条更重的路线。

如果你在意版本对应关系，尽量使用和这份仓库主线接近的版本，例如 `25.11` 这一代。

这一步的目标不是一次把整套个人系统全部恢复，而是先得到一个“能启动、能联网、能继续操作”的基础系统。

### 第 3 步：首次进入系统后，再把镜像写回已安装系统

Live ISO 里改的 `/etc/nix/nix.conf` 不会自动带到你刚装好的系统里，所以第一次进入新系统后，建议再做一次同样的事情：

```bash
sudo cp /etc/nix/nix.conf /etc/nix/nix.conf.bak
sudo nano /etc/nix/nix.conf
```

加入：

```conf
substituters = https://mirror.sjtu.edu.cn/nix-channels/store https://cache.nixos.org/
```

然后执行：

```bash
sudo systemctl restart nix-daemon
```

这样你后面安装浏览器、代理、GitHub Desktop，以及最后恢复仓库时，都会优先走国内镜像。

### 第 4 步：先补齐恢复所需的关键工具

第一次进入基础系统后，你真正需要的不是马上恢复全部配置，而是先让下面这些条件成立：

- 有浏览器，能登录 GitHub
- 有代理软件，能恢复订阅
- 有 GitHub Desktop 或 Git，能拿到仓库
- 有文件管理器，方便直接在图形界面里下载、解压、移动文件

这里顺手说清楚一个容易误解的点：  
下面列出来的工具，指的是完整配置恢复后会由这份仓库接管的目标状态。在“基础系统阶段”，它们未必已经存在；你可以先用系统自带的同类工具，也可以临时补装。

仓库里对应的目标工具如下：

- `firefox`
  位置：`modules/system/packages.nix`
  用途：浏览网页、登录 GitHub、下载需要的东西。
- `google-chrome`
  位置：`modules/home/applications/web.nix`
  用途：第二个浏览器备用。
- `mihomo`
  位置：`modules/system/packages.nix`
  用途：无 GUI 的代理核心，适合恢复早期兜底。
- `throne`
  位置：`modules/home/applications/web.nix`
  用途：Qt 代理客户端，适合刚开始恢复网络时优先使用。
- `clash-verge-rev`
  位置：`modules/home/applications/web.nix`
  用途：完整桌面环境可用后继续作为代理 GUI。
- `github-desktop`
  位置：`modules/home/development/toolchain.nix`
  用途：图形化同步你后续真正要恢复的仓库。

特别提醒：刚开始恢复网络时，尽量优先使用 `throne` 这类 Qt 应用，或者直接用 `mihomo` 这种无 GUI 核心。`clash-verge-rev` 依赖 WebView 渲染，早期系统里如果显卡、WebView、Wayland/X11 环境还没完全稳定，可能出现界面打不开或渲染异常，导致代理还没恢复就先卡住。

如果基础系统里已经有浏览器，那就直接用；如果没有，再补装一个即可。

另外，这个仓库虽然带默认代理配置，但**在你真正执行 `nixos-rebuild switch --flake .` 之前，它不会影响当前基础系统**。  
也就是说，你完全可以按下面的顺序来：

1. 先用镜像把基础系统装好
2. 先把代理软件装上并恢复订阅
3. 再去 clone 或下载这份完整配置
4. 最后才执行 `nixos-rebuild switch --flake .`

在这个流程下，没有必要专门设计一个“去掉默认代理再恢复”的环节。

这里还有一个很实用的小思路：  
第一次恢复时，不一定非得先 `git clone`。如果你更想走图形界面，可以先：

1. 用浏览器打开 GitHub 仓库页面
2. 直接下载仓库 ZIP
3. 用文件管理器解压
4. 在解压后的目录里“右键 -> 在此处打开终端”
5. 再执行最后那条恢复命令

这样前期就不用纠结终端里克隆仓库的细节，操作上会更接近普通图形化系统的使用习惯。

### 第 5 步：先恢复代理，再登录 GitHub 拿到完整配置

建议顺序是：

1. 优先用 `throne` 或 `mihomo` 导入/加载订阅并确认代理可用
2. 再用浏览器登录 GitHub
3. 然后用 `github-desktop`、`git clone`，或者直接下载仓库 ZIP 的方式拿到你真正的完整配置仓库

这一步完成后，你就可以从“基础系统”切到“完整个人系统”。

### 第 6 步：检查中文用户目录问题

这个仓库现在默认把 `Desktop / Documents / Downloads / Music / Pictures / Public / Templates / Videos` 固定成英文目录，避免像 `~/Pictures` 这类路径在恢复时失效。

但如果你的系统已经提前生成过中文目录，比如：

- `~/桌面`
- `~/下载`
- `~/文档`
- `~/图片`

而且里面已经有文件，那么在最终恢复前，最好先手动把内容迁移到英文目录里。因为这个仓库里的部分配置直接引用了英文路径，例如：

- `~/Pictures`
- `~/Pictures/Screenshots`

如果你后续打算直接复用别人仓库里的配置，也一定要注意这个问题：  
**目录结构可以学，硬件文件不能照抄。**

尤其是下面这些内容：

- `hardware-configuration.nix`
- 磁盘分区对应关系
- 文件系统 UUID
- 引导盘和根分区挂载方式

这些东西都必须以你自己这台机器生成出来的版本为准，不能直接复制粘贴别人的。GitHub issue 区里这类因为照抄硬件配置而翻车的例子其实非常多。

### 第 7 步：满足条件后再执行最终恢复命令

当下面这些条件都满足时，再执行你真正的最终恢复：

- 镜像安装已经成功，系统能正常启动
- `throne`、`mihomo` 或其他代理方案已经可正常联网
- 浏览器已经能登录 GitHub
- `github-desktop`、`git` 或浏览器下载 ZIP 的方式已经拿到你的完整配置
- 用户目录已经确认不会被中文路径卡住

然后进入你的完整配置仓库目录，再执行：

```bash
sudo nixos-rebuild switch --flake .
```

## 可选高级路线：直接用 flake 终端安装

如果你已经非常熟悉分区、挂载、`nixos-generate-config` 和 `nixos-install --flake` 这套流程，那么当然也可以直接走“第一次安装就按仓库 flake 装进去”的路线。  
但对于这份仓库的恢复场景，我个人现在更推荐上面的图形安装器 + 镜像 + 后续恢复的路径，因为更顺手，也更符合先把网络和浏览器恢复起来的实际节奏。

## References

- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/zh/)
  这份资料写得挺不错，比较适合先自己配合 AI 折腾一会，再回来看，理解速度会快很多。

## 这个仓库在意什么

- 分层清楚：避免把所有逻辑塞进一个大文件。
- 可迁移：把“可复用模块”和“主机专属差异”分开。
- 可维护：入口固定，读配置时路径稳定。

---

## 入口文件

- 系统入口：`hosts/nixos/configuration.nix`
- 用户入口：`home/eurekaimer/home.nix`

`home.nix` 只导入 4 个顶层模块：

1. `modules/home/desktop.nix`
2. `modules/home/core.nix`
3. `modules/home/development.nix`
4. `modules/home/applications.nix`

`modules/home/applications.nix` 也负责通过 Home Manager 的 `xdg.mimeApps` 管理桌面默认打开方式，这样文件关联不会散落在 Niri 或 Noctalia 的配置里。

---

## Home 层次（重点：Niri/Noctalia）

```text
modules/home
├── desktop.nix
│   ├── desktop/noctalia.nix
│   ├── desktop/niri.nix
│   ├── desktop/rofi.nix       （可选，默认不启用）
│   └── desktop/waybar.nix     （可选，默认不启用）
├── core.nix
│   ├── core/shell.nix
│   ├── core/kitty.nix
│   ├── core/fastfetch.nix
│   ├── core/ui.nix
│   └── core/yazi.nix
├── development.nix
│   ├── development/neovim.nix
│   └── development/toolchain.nix
└── applications.nix
    ├── applications/knowledge.nix
    ├── applications/documents.nix
    ├── applications/media.nix
    ├── applications/web.nix            （浏览器、Clash Verge、Throne）
    ├── applications/transfer.nix
    └── applications/communication.nix
```

说明：

- `desktop`：桌面会话层（Noctalia + Niri）
- `core`：命令行与基础 UI 体验
- `development`：开发工具链
- `applications`：日常应用集合

当前默认打开方式：

- PDF 使用 `sioyek`
- 常见图片格式使用 `imv`
- `mihomo` 作为系统级代理核心
- `throne` 作为恢复早期优先使用的代理 GUI，`clash-verge-rev` 保留给完整桌面环境
- 这些关联统一在 `modules/home/applications.nix` 里的 `xdg.mimeApps` 管理

---

## System 层次

`configuration.nix` 只保留三类导入：

1. `./hardware-configuration.nix`
2. `./host-local.nix`
3. `../../modules/system/system.nix`

```text
modules/system
├── system.nix
├── base.nix
├── users.nix
├── locale.nix
├── desktop.nix
├── graphics.nix
├── gaming.nix
├── packages.nix        （通用命令行工具、Firefox、mihomo）
└── graphics-intel.nix   （可选，Intel 机器按需启用）
```

---

## 硬件文件放置（非常重要）

`hardware-configuration.nix` 是**机器绑定文件**，应放在：

- `hosts/<hostname>/hardware-configuration.nix`

当前仓库示例：

- `hosts/nixos/hardware-configuration.nix`

迁移到新电脑时：

1. 在新机器生成硬件文件。
2. 放到 `hosts/<new-host>/hardware-configuration.nix`。
3. 新建 `hosts/<new-host>/configuration.nix` 与 `hosts/<new-host>/host-local.nix`。
4. 复用 `modules/system/*` 与 `modules/home/*` 通用层。

建议把主机差异（主机名、代理、端口、特殊内核参数）统一收敛到 `host-local.nix`。

---

## 重建命令

```bash
sudo nixos-rebuild switch --flake .#nixos
```

---
