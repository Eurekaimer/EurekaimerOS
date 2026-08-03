{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    nil             # Nix 语言服务器
    nixfmt-rfc-style # Nix 格式化（RFC 101 风格）
  ];
}
