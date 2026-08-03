{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    go       # Go 编译器/工具链
    gopls    # Go 语言服务器
    delve    # Go 调试器
    gotools  # Go 官方工具集（goimports 等）
  ];

  home.sessionVariables = {
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];
}
