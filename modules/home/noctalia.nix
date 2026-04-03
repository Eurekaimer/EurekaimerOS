{ pkgs, inputs, ... }: {
  imports = [
    inputs.noctalia.homeModules.default # 引入 Noctalia 模块
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        position = "top"; # 你可以改成 right, left 或 bottom
        density = "compact";
        widgets = {
          left = [
            { id = "ControlCenter"; useDistroLogo = true; }
            { id = "Network"; }
            { id = "Bluetooth"; }
          ];
          center = [
            { id = "Workspace"; labelMode = "none"; }
          ];
          right = [
            { id = "Battery"; }
            { id = "Clock"; formatHorizontal = "HH:mm"; }
          ];
        };
      };
      general = {
        radiusRatio = 0.2;
        # avatarImage = "/home/eurekaimer/.face"; # 确保路径正确或注释掉
      };
    };
  };
}