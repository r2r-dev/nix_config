# Home-manager modules, exposed as `homeManagerModules.<dirname>`.
# `homeManagerModules.default` imports all of them and is added to every
# home-manager user (home-manager.sharedModules in flake.nix); like the NixOS
# modules they are inert until their my.* options are set.
let
  modules = import ../../lib/import-dir.nix ./.;
in
modules // { default.imports = builtins.attrValues modules; }
