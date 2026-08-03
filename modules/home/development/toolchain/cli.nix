{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    fd       # find 的现代化替代（快、易用）
    ripgrep  # grep 的现代化替代（快、默认递归）
    sqlite   # SQLite 命令行
  ];
}
