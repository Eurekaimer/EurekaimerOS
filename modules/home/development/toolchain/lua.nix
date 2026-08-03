{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    lua-language-server # Lua 语言服务器
    stylua              # Lua 格式化工具
  ];
}
