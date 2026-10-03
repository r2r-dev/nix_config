# Packages defined in this repo, as a function of a package set.
# Applied to the hosts' nixpkgs through overlays/default.nix and exposed as
# the flake's `packages` output.
#
# Out-of-tree kernel modules are not listed here: they must be built against
# the host's kernel, so modules use `config.boot.kernelPackages.callPackage`.
pkgs: {
  libfprint-focaltech = pkgs.callPackage ./libfprint-focaltech { };
}
