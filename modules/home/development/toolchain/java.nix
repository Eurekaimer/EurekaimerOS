{ pkgs, pkgs-unstable, ... }:

let
  jdk = pkgs.jdk21;
in
{
  home.packages = [
    pkgs.maven
    pkgs.gradle
    pkgs.jdt-language-server
    jdk
    pkgs-unstable.jetbrains.idea-oss
  ];

  home.sessionVariables = {
    JAVA_HOME = "${jdk}";
    JDK_HOME = "${jdk}";
  };
}
