# Every module directory below here (grouped as core/, hardware/, desktop/,
# gaming/, services/) is exposed as `nixosModules.<dirname>`.
# `nixosModules.default` imports all of them; each module is inert until its
# options are set, so hosts only set options and never list imports.
# Option paths follow the directories: hardware/nvidia -> my.hardware.nvidia;
# core modules sit directly under my.* (core/user -> my.user).
let
  modules = import ../../lib/import-dir.nix ./.;
in
modules // { default.imports = builtins.attrValues modules; }
