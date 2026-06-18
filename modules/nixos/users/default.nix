# Users: the primary (immutable) r2r user, with its password sourced from
# the agenix secret.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.users;
in
{
  options.modules.nixos.users = {
    enable = lib.mkEnableOption "the primary r2r user";
    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wheel" ];
      description = "Additional groups for the r2r user.";
      example = [
        "wheel"
        "input"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      mutableUsers = false;
      users.r2r = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets."r2r.passwd".path;
        inherit (cfg) extraGroups; # Enable 'sudo' for the user (via wheel).
      };
    };
  };
}
