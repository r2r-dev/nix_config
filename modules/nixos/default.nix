# Auto-import every module directory in this folder.
# Each subdirectory is expected to contain a `default.nix`, and is exposed
# under `outputs.nixosModules.<dirname>`. Adding a new module is just a
# matter of creating the directory — no need to edit this file.
let
  entries = builtins.readDir ./.;
  moduleNames = builtins.filter (name: entries.${name} == "directory") (
    builtins.attrNames entries
  );
in
builtins.listToAttrs (
  map (name: {
    inherit name;
    value = import (./. + "/${name}");
  }) moduleNames
)
