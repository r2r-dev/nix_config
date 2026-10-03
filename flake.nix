{
  description = "My NixOS flake";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      nixpkgs,
      agenix,
      chaotic,
      home-manager,
      impermanence,
      jovian-nixos,
      outoftree,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";

      # Modules shared by every host.
      commonModules = [
        (
          { pkgs, ... }:
          {
            nixpkgs.overlays = [ (import ./overlays { inherit outoftree system; }) ];
            nixpkgs.config.allowUnfree = true;
            environment.systemPackages = [
              agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];
          }
        )
        agenix.nixosModules.default
        chaotic.nixosModules.default
        jovian-nixos.nixosModules.default
        home-manager.nixosModules.home-manager
        impermanence.nixosModules.impermanence
        self.nixosModules.default
      ];

      # Every directory in ./hosts is a host; its name is the attribute name.
      mkHost =
        name: path:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outoftree; };
          modules = commonModules ++ [
            { networking.hostName = name; }
            path
          ];
        };
    in
    {
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home;

      nixosConfigurations = lib.mapAttrs mkHost (import ./lib/import-dir.nix ./hosts);

      # `nix fmt` formats the tree (nixfmt, 80 columns); `nix fmt -- --ci` only checks it.
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree.override {
        settings.formatter.nixfmt.options = [ "--width=80" ];
      };

      # `nix flake check` evaluates every host; `nix build .#checks.<system>.<host>`
      # builds its full system closure.
      checks.${system} = lib.mapAttrs (
        _: host: host.config.system.build.toplevel
      ) self.nixosConfigurations;
    };
}
