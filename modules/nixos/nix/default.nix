# Nix: enable flakes/nix-command, allow unfree packages, and persist the
# Nix/NixOS state directories on impermanent hosts.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.nix;
in
{
  options.modules.nixos.nix = {
    enable = lib.mkEnableOption "Nix daemon settings (flakes, unfree)";
  };

  config = lib.mkIf cfg.enable {
    environment.persistence.main =
      lib.mkIf config.modules.nixos.impermanence.enable
        {
          hideMounts = true;
          directories = [
            "/etc/nixos"
            "/etc/nix"
            "/var/lib/nixos"
          ];
        };
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
  };
}
