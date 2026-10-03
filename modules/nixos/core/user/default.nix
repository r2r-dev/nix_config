# User: the primary (immutable) user. Other modules refer to it through
# `config.my.user.name` instead of hard-coding it.
#
# The login password comes from the agenix secret
# `secrets/<name>.passwd.age`.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.user;
in
{
  options.my.user = {
    enable = lib.mkEnableOption "the primary user";
    name = lib.mkOption {
      type = lib.types.str;
      default = "r2r";
      description = "Login name of the primary user.";
    };
    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wheel" ];
      description = "Additional groups for the primary user.";
      example = [
        "wheel"
        "input"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets."${cfg.name}.passwd".file =
      ../../../../secrets + "/${cfg.name}.passwd.age";

    users = {
      mutableUsers = false;
      users.${cfg.name} = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets."${cfg.name}.passwd".path;
        inherit (cfg) extraGroups; # Enable 'sudo' for the user (via wheel).
      };
    };
  };
}
