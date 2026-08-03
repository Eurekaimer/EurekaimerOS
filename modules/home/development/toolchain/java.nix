{ pkgs, pkgs-unstable, ... }:

let
  jdk = pkgs.jdk21;
in
{
  eureka.software.home = [
    pkgs.maven                    # Java 构建工具（Maven）
    pkgs.gradle                   # Java 构建工具（Gradle）
    pkgs.jdt-language-server      # Eclipse JDT Java 语言服务器
    jdk                           # JDK 21（见下方 let 绑定）
    pkgs-unstable.jetbrains.idea-oss # IntelliJ IDEA Community（unstable）
  ];

  home.sessionVariables = {
    JAVA_HOME = "${jdk}";
    JDK_HOME = "${jdk}";
  };
}
