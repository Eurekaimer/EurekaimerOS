{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bear
    clang-tools
    cmake
    cppcheck
    gcc
    gdb
    gnumake
    lldb
    meson
    ninja
    pkg-config
    valgrind
  ];
}
