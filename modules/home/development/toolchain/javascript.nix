{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    nodejs_22 # Node.js 22 LTS
    pnpm      # 快速、省磁盘的 Node 包管理器
  ];
}
