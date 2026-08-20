{
  description = "My NixOS flake";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home & secrets
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "";
      inputs.home-manager.follows = "";
    };

    # Packages & overlays
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nur.url = "github:nix-community/NUR";
    proton-cachyos = {
      url = "github:powerofthe69/proton-cachyos-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.

    # Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Steamdeck related options
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Out-of-tree packages defined in this repo
    outoftree = {
      url = "path:./pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.chaotic.follows = "chaotic";
    };
  };

  outputs =
    {
      self,
      agenix,
      chaotic,
      nixpkgs,
      nix-flatpak,
      nixos-hardware,
      jovian-nixos,
      home-manager,
      impermanence,
      outoftree,
      proton-cachyos,
      nur,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit inputs;

      system = "x86_64-linux";

      myOverlays = import ./overlays {
        inherit outoftree system;
      };

      # Modules shared by every host.
      commonModules = [
        {
          nixpkgs.overlays = [ myOverlays ];
          nixpkgs.config.allowUnfree = true;
        }
        agenix.nixosModules.default
        chaotic.nixosModules.default
        jovian-nixos.nixosModules.default
        home-manager.nixosModules.home-manager
        impermanence.nixosModules.impermanence
        {
          environment.systemPackages = [
            agenix.packages.${system}.default
          ];
        }
      ];

      # Build a NixOS configuration for the host named `name`, adding any
      # host-specific modules on top of the shared set.
      mkSystem =
        name: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              system
              outoftree
              outputs
              inputs
              ;
          };
          modules = commonModules ++ extraModules ++ [ ./machines/${name} ];
        };
    in
    {
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home;

      nixosConfigurations = {
        annata = mkSystem "annata" [
          nixos-hardware.nixosModules.gpd-pocket-4
          nix-flatpak.nixosModules.nix-flatpak
        ];
        samsara = mkSystem "samsara" [
          { nixpkgs.overlays = [ proton-cachyos.overlays.default ]; }
          nur.modules.nixos.default
        ];
      };
    };
}
