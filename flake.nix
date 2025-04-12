{
  description = "My NixOS flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    nixpkgs-alt = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
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
      url = "github:nix-community/home-manager/release-24.11";
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
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      impermanence,
      outoftree,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      overlay = final: prev: {
        linux-firmware = prev.linux-firmware.overrideAttrs rec {
            version = "";
            src = prev.fetchzip {
              url = "";
              hash = "";
            };
        };
      };
    in
    {
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home;
      nixosConfigurations = {
        samsara = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              inputs
              system
              outoftree
              outputs
              overlay
              ;
            unstable = import nixpkgs-unstable {
              inherit inputs system;
              config.allowUnfree = true;
            };
          };
          modules = [
            agenix.nixosModules.default
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
