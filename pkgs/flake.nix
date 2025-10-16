{
  description = "Out Of Tree";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    };
  };

  outputs =
    {
      nixpkgs,
      chaotic,
      ...
    }:
    let
      forAllSys = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    in
    {
      pkgs = forAllSys (
        _:
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config = {
              allowUnfree = true;
            };
            overlays = [ chaotic.overlays.cache-friendly ]; # IMPORTANT
          };
        in
        rec {
          it87 = pkgs.callPackage ./it87 {
            inherit (pkgs.linuxPackages_zen) kernel;
          };
        }
      );
    };
}
