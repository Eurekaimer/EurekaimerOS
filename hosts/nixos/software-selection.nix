# Software and optional-feature choices for this host.
#
# This file intentionally contains data only.  flake.nix passes the same
# attribute set to NixOS and Home Manager as `softwareSelection`, so the two
# module systems can share choices without sharing option definitions.
#
# Run ../../scripts/select-software.sh to regenerate it interactively.  The
# checked-in defaults preserve the complete setup that existed before package
# selection was introduced.
{
  system = {
    power = {
      tlp = true;
      adaptivePolicy = true;
      thermal = true;
      sleep = true;
      diagnostics = true;
    };
    mounts = true;
    gaming = true;

    packages = {
      baseCli = true;
      network = true;
      monitoring = true;
      archive = true;
      dos = true;
    };

    desktop = {
      printing = true;
      bluetooth = true;
    };

    virtualisation = {
      docker = true;
      virtualMachines = true;
    };
  };

  home = {
    core = {
      shell = true;
      kitty = true;
      fastfetch = true;
      ui = true;
      yazi = true;
      trashCleanup = true;
    };

    applications = {
      knowledge = true;
      documents = true;
      media = true;
      web = true;
      fileManager = true;
      transfer = true;
      communication = true;
    };

    development = {
      neovim = true;
      editors = true;
      cli = true;
      shell = true;
      nix = true;
      lua = true;
      markdown = true;
      python = true;
      javascript = true;
      java = true;
      go = true;
      rust = true;
      cpp = true;
      latex = true;
    };
  };

  # Personal modules are kept separate from general applications and tools.
  personal = {
    lexigraph = true;
    komariCall = true;
    campusLogin = true;
    dockerAss = true;
    hot100Assistant = true;
  };
}
