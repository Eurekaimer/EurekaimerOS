{ lib, softwareSelection, ... }:

{
  # Personal commands are deliberately separate from generic applications and
  # shell tools.  Their modules may contain campus-specific URLs or private
  # directory conventions that should not silently become portable defaults.
  imports =
    lib.optionals softwareSelection.personal.campusLogin [ ./personal/campus-login.nix ]
    ++ lib.optionals softwareSelection.personal.dockerAss [ ./personal/docker-ass.nix ];

  assertions = [
    {
      assertion =
        !softwareSelection.personal.campusLogin
        || softwareSelection.home.applications.web;
      message = "campus-login requires the web application group (Chrome/Chromium).";
    }
    {
      assertion =
        !softwareSelection.personal.dockerAss
        || softwareSelection.system.virtualisation.docker;
      message = "docker-ass requires system.virtualisation.docker in software-selection.nix.";
    }
    {
      assertion =
        !softwareSelection.personal.hot100Assistant
        || softwareSelection.home.development.editors;
      message = "Hot100 Assistant requires the VSCode editor group.";
    }
  ];
}
