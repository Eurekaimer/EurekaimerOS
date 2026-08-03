{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    uv      # Python 包/环境管理器（替代 pip/venv，速度极快）
    jupyter # Jupyter Notebook/Lab（数据科学）
    pyright # Python 类型检查/语言服务器
  ];
}
