{ ... }:

{
  services.flatpak = {
    enable = true;

    remotes = [{
      name = "flathub-sjtu";
      location = "https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo";
    }];

    packages = [
      "com.tencent.WeChat"
      "io.github.Predidit.Kazumi"
    ];

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
