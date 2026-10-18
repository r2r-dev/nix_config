# Nix: flakes/nix-command, automatic gc + store optimisation,
# and the Nix/NixOS state directories persisted on impermanent
# hosts. (Unfree packages are allowed for every host in flake.nix.)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.nix;
in
{
  options.my.nix = {
    enable = lib.mkEnableOption "Nix daemon settings (flakes)";

    gc = {
      enable = lib.mkEnableOption "weekly garbage collection" // {
        default = true;
      };
      keep = lib.mkOption {
        type = lib.types.str;
        default = "30d";
        example = "14d";
        description = ''
          Delete system generations (and their store paths) older than this.
          Generations newer than it stay selectable in the boot menu, up to
          the bootloader configurationLimit.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    my.persist = {
      directories = [
        "/etc/nixos"
        "/etc/nix"
        "/var/lib/nixos"
      ];
    };
    # Flakes fetch git inputs and read git working trees.
    environment.systemPackages = [ pkgs.git ];

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };

      gc = lib.mkIf cfg.gc.enable {
        automatic = true;
        dates = "weekly";
        persistent = true;
        randomizedDelaySec = "45min";
        options = "--delete-older-than ${cfg.gc.keep}";
      };
    };
  };
}
