# 配置文档

这里解释本仓库自身的 NixOS 配置，而不是复制各上游项目的使用手册。建议从架构开始，再按需要阅读具体模块。

+ [配置架构](architecture_zh-CN.md)
  + flake 输入、主机入口、NixOS 与 Home Manager 的边界
  + stable/unstable 软件包的传递方式
+ [系统层配置](system_zh-CN.md)
  + 启动、网络、区域与字体、图形、电源、存储、虚拟化、游戏
+ [桌面与用户界面](desktop_zh-CN.md)
  + Niri、Noctalia、GTK、截图、启动器及配置文件映射
+ [应用软件](applications_zh-CN.md)
  + 浏览器、知识管理、文档、媒体、通信和下载工具
+ [开发环境](development_zh-CN.md)
  + 编辑器、语言工具链、CLI 与 AI 工具
+ [软件选择与配置生成](software-selection_zh-CN.md)
  + 双语 CLI、选择文件、模块开关、rebuild 与软件数量报告
+ [个人专用模块](personal_zh-CN.md)
  + 个人项目、校园认证和本机目录约定的独立边界
+ [构建和维护](operations_zh-CN.md)
  + 重建、验证、恢复、主机迁移和电源诊断

[English documentation](index.md)

软件名称后的“官方项目”链接用于标明来源并尊重上游贡献；本地配置的具体行为仍以本目录文档和对应 `.nix` 文件为准。

完整软件与服务清单统一维护在根目录的 [`software.md`](../software.md)，不要在主题文档中复制另一份完整清单。
