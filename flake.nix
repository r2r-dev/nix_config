{
  description = "My NixOS flake";

  inputs = {
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ucodenix = {
      url = "github:e-tho/ucodenix";
    };
    outoftree = {
      url = "path:./pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      agenix,
      chaotic,
      nixpkgs,
      nixpkgs-unstable,
      nixos-hardware,
      home-manager,
      impermanence,
      outoftree,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home;
      nixosConfigurations = {
        annata = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              inputs
              system
              outoftree
              outputs
              ;
            unstable = import nixpkgs-unstable {
              inherit inputs system;
              config.allowUnfree = true;
            };
          };
          modules = [
            nixos-hardware.nixosModules.gpd-pocket-4
            agenix.nixosModules.default
            chaotic.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
              imports = [ home-manager.nixosModules.home-manager ];

              home-manager.users.r2r =
                { ... }:
                {
                  imports = [
            #        #impermanence.homeManagerModules.impermanence
            #        outputs.homeManagerModules.impermanence
                  ];
                };
            }
            #impermanence.nixosModules.impermanence
            ./machines/annata
          ];
        };
        samsara = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              inputs
              system
              outoftree
              outputs
              ;
            unstable = import nixpkgs-unstable {
              inherit inputs system;
              config.allowUnfree = true;
            };
          };
          modules = [
            agenix.nixosModules.default
            chaotic.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
              imports = [ home-manager.nixosModules.home-manager ];

              home-manager.users.r2r =
                { ... }:
                {
                  imports = [
                    impermanence.homeManagerModules.impermanence
                    outputs.homeManagerModules.impermanence
                  ];
                };
            }
            impermanence.nixosModules.impermanence
            ./machines/samsara
          ];
        };
      };
    };
}
