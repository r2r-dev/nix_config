# Every module directory here is exposed as `nixosModules.<dirname>`.
# `nixosModules.default` imports all of them; each module is inert until its
# `enable` option is set, so hosts only toggle options and never list imports.
# Adding a module is just creating the directory.
let
  modules = import ../../lib/import-dir.nix ./.;
in
modules // { default.imports = builtins.attrValues modules; }
