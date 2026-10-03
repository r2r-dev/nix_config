# Map every subdirectory of `dir` (each holding a `default.nix`) to its path:
#   importDir ./modules/nixos => { bluetooth = ./modules/nixos/bluetooth; ... }
# Paths (rather than imported functions) keep file names in error messages.
dir:
let
  entries = builtins.readDir dir;
  names = builtins.filter (name: entries.${name} == "directory") (
    builtins.attrNames entries
  );
in
builtins.listToAttrs (
  map (name: {
    inherit name;
    value = dir + "/${name}";
  }) names
)
