# Profile "gaming": Steam, the gamescope session, GameMode and controllers.
# Resolution etc. of the session are set per host.
{ config, lib, ... }:
{
  options.my.profiles.gaming.enable = lib.mkEnableOption "the gaming profile";

  config = lib.mkIf config.my.profiles.gaming.enable {
    my = lib.mapAttrsRecursive (_: lib.mkDefault) {
      gaming = {
        steam.enable = true;
        gamemode.enable = true;
        session.enable = true;
      };
      hardware.xbox.enable = true;
    };
  };
}
