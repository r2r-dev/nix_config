{
  description = "Out Of Tree";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      forAllSys = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    in
    {
      pkgs = forAllSys (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        rec {
          linux_zen = pkgs.callPackage ./linux_zen { };
          it87 = pkgs.callPackage ./it87 { kernel = linux_zen; };
        }
      );
    };
}
