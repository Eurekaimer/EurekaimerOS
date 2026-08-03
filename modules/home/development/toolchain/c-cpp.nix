{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    bear        # 生成 compile_commands.json（配合 clangd）
    clang-tools # clangd 等 LLVM 工具
    cmake       # C/C++ 构建系统
    cppcheck    # C/C++ 静态分析
    gcc         # GNU C 编译器
    gdb         # GNU 调试器
    gnumake     # make 构建工具
    lldb        # LLVM 调试器
    meson       # 现代构建系统
    ninja       # 极速构建系统（meson 后端）
    pkg-config  # 依赖查找工具
    valgrind    # 内存检测工具
  ];
}
