# DOS 相关（系统级）
{ pkgs, ... }:

{
  eureka.software.system = with pkgs; [
    dosbox-staging # DOS 游戏模拟器（小众，可删建议见 readme/software.md）
  ];
}
