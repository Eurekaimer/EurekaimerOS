{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    cargo         # Rust 包管理器/构建工具
    clippy        # Rust 代码检查（lint）
    rust-analyzer # Rust 语言服务器
    rustc         # Rust 编译器
    rustfmt       # Rust 格式化工具
  ];

  home.sessionVariables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}
