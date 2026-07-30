{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cargo
    clippy
    rust-analyzer
    rustc
    rustfmt
  ];

  home.sessionVariables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}
