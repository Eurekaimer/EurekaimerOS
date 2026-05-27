{ pkgs, ... }:

{
  home.packages = with pkgs; [
    go
    gopls
    delve
    gotools
  ];

  home.sessionVariables = {
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];
}
