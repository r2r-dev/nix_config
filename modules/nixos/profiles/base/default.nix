# Profile "base": what every host runs. Profiles only turn modules on with
# lib.mkDefault, so a host can still override any of it.
{ config, lib, ... }:
{
  options.my.profiles.base.enable = lib.mkEnableOption "the base profile";

  config = lib.mkIf config.my.profiles.base.enable {
    my = lib.mapAttrsRecursive (_: lib.mkDefault) {
      boot.enable = true;
      kernel.enable = true;
      locale.enable = true;
      nix.enable = true;
      secrets.enable = true;
      ssh.enable = true;
      user.enable = true;
    };
  };
}
