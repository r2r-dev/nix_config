# Profile "workstation": an interactive machine with a desktop.
# The desktop environment itself is chosen per host.
{ config, lib, ... }:
{
  options.my.profiles.workstation.enable =
    lib.mkEnableOption "the workstation profile";

  config = lib.mkIf config.my.profiles.workstation.enable {
    my = lib.mapAttrsRecursive (_: lib.mkDefault) {
      profiles.base.enable = true;
      hardware.bluetooth.enable = true;
      desktop.sound.enable = true;
    };
  };
}
