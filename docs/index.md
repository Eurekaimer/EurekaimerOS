# Configuration Documentation

These documents explain this repository's configuration rather than duplicating upstream manuals. Start with the architecture, then open only the area you need.

+ [Architecture](architecture.md)
  + Flake inputs, host entry point, NixOS/Home Manager boundary, stable/unstable package flow
+ [System](system.md)
  + Boot, network, locale, fonts, graphics, power, storage, gaming, and virtualization
+ [Desktop](desktop.md)
  + Niri, Noctalia, GTK, screenshots, UI configuration mapping
+ [Applications](applications.md)
  + Browser, documents, media, communication, and transfer tools
+ [Development](development.md)
  + Editors, language toolchains, CLI, notebooks, and AI tools
+ [Software selection](software-selection.md)
  + Bilingual wizard, selection data, module switches, rebuild, and package counts
+ [Personal modules](personal.md)
  + Isolated owner projects, campus behavior, and host directory conventions
+ [Operations](operations.md)
  + Rebuilds, verification, recovery, migration, power diagnostics, and repository synchronization

[中文配置文档](index_zh-CN.md)

Software links identify and credit upstream projects. Repository-specific behavior is documented here and in the linked `.nix` files.

The single complete package and service inventory lives in [`software.md`](../software.md); topic documents should not duplicate a second exhaustive list.
