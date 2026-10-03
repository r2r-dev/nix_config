# Find module directories (those holding a `default.nix`) below `dir`, at any
# depth, and map each directory name to its path:
#   importDir ./modules/nixos
#   => { boot = ./modules/nixos/core/boot; nvidia = ./modules/nixos/hardware/nvidia; ... }
# Grouping directories (without a default.nix) are only descended into.
# Directory names must be unique. Paths (rather than imported functions) keep
# file names in error messages.
let
  find =
    dir:
    let
      entries = builtins.readDir dir;
      subdirs = builtins.filter (n: entries.${n} == "directory") (
        builtins.attrNames entries
      );
    in
    builtins.concatMap (
      name:
      let
        path = dir + "/${name}";
      in
      if builtins.pathExists (path + "/default.nix") then
        [
          {
            inherit name;
            value = path;
          }
        ]
      else
        find path
    ) subdirs;
in
dir:
let
  found = find dir;
  names = map (m: m.name) found;
  duplicates = builtins.filter (
    n: builtins.length (builtins.filter (x: x == n) names) > 1
  ) names;
in
if duplicates != [ ] then
  throw "import-dir: duplicate module directory names: ${toString duplicates}"
else
  builtins.listToAttrs found
