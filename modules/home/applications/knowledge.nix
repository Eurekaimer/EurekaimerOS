{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    obsidian # Markdown 知识库（双链笔记）
    zotero   # 文献管理（学术引用）
  ];
}
