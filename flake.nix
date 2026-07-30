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
      url = "path:/home/eurekaimer/Documents/GitHub/lexigraph";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
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
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs-unstable; };

        modules = [
          ./hosts/nixos/configuration.nix
          inputs.komari-call.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.eurekaimer = import ./home/eurekaimer/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs pkgs-unstable; };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
}
