{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    bash-language-server # Bash 语言服务器（补全/诊断）
  ];
}
