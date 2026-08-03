{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    marksman # Markdown 语言服务器
  ];
}
