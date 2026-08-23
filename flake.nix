{
  description = "Eurekaimer's Modern NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    komari-call = {
      url = "git+https://github.com/Eurekaimer/KOMABELIKA.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lexigraph = {
      url = "github:Eurekaimer/lexigraph/3a562809ede3132916ebed592a9fc2ea88ef6098";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hot100-assistant = {
      url = "github:Eurekaimer/hot100-assistant/82cf08aabceadc706c98d433bbf78a992899c706";
      flake = false;
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      # This is a plain attribute set rather than a NixOS/Home Manager module.
      # Passing the same value to both module systems keeps package choices in
      # one host-local file without coupling their option namespaces.
      softwareSelection = import ./hosts/nixos/software-selection.nix;
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      checks.${system}.source-hygiene = pkgs.runCommand "source-hygiene" { } ''
        if find ${self} -type l -lname '/nix/store/*' -print -quit | grep -q .; then
          echo "absolute /nix/store symlink found in flake source" >&2
          exit 1
        fi
        touch "$out"
      '';

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs-unstable softwareSelection; };

        modules = [
          ./hosts/nixos/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.eurekaimer = import ./home/eurekaimer/home.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs pkgs-unstable softwareSelection;
            };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
}
