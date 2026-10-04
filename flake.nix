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

    # Steam Deck bits. Not only options: its module overlays steam (steam-jupiter +
    # steamos-session-select), gamescope and mangohud, which the gamescope session uses.
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
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
            nixpkgs.overlays = [ self.overlays.default ];
            nixpkgs.config.allowUnfree = true;
            # Home-manager uses the system's nixpkgs (overlays, unfree) and
            # installs user packages into /etc/profiles/per-user.
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [ self.homeManagerModules.default ];
            # Lets home-manager modules reach flake inputs (e.g. noctalia).
            home-manager.extraSpecialArgs = { inherit inputs; };
            environment.systemPackages = [
              agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];
          }
        )
        agenix.nixosModules.default
        chaotic.nixosModules.default
        jovian-nixos.nixosModules.default # see input comment: overlay is in use
        home-manager.nixosModules.home-manager
        impermanence.nixosModules.impermanence
        self.nixosModules.default
      ];

      # Every directory in ./hosts is a host; its name is the attribute name.
      # hosts/<name>/home.nix, if present, is the primary user's
      # home-manager config on that host.
      mkHost =
        name: path:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules =
            commonModules
            ++ [
              { networking.hostName = name; }
              path
            ]
            ++ lib.optional (builtins.pathExists (path + "/home.nix")) (
              { config, ... }:
              {
                home-manager.users.${config.my.user.name} = path + "/home.nix";
              }
            );
        };
    in
    {
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home;
      overlays.default = import ./overlays;

      packages.${system} =
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        import ./pkgs pkgs
        // {
          # Built against the default kernel here; hosts build it against their own.
          it87 = pkgs.linuxPackages_zen.callPackage ./pkgs/it87 { };
        };

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
