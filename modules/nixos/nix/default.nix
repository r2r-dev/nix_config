# Nix: enable flakes/nix-command and persist the Nix/NixOS state
# directories on impermanent hosts. (Unfree packages are allowed for every
# host in flake.nix.)
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.nix;
in
{
  options.my.nix = {
    enable = lib.mkEnableOption "Nix daemon settings (flakes)";
  };

  config = lib.mkIf cfg.enable {
    environment.persistence.main = lib.mkIf config.my.impermanence.enable {
      hideMounts = true;
      directories = [
        "/etc/nixos"
        "/etc/nix"
        "/var/lib/nixos"
      ];
    };
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
