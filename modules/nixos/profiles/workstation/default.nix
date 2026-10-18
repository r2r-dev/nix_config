# Profile "workstation": an interactive machine with a desktop.
# The desktop environment itself is chosen per host. Also enables the
# primary user's home-manager cli and apps modules.
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

    home-manager.users.${config.my.user.name}.my =
      lib.mapAttrsRecursive (_: lib.mkDefault)
        {
          cli.enable = true;
          ssh.enable = true;
          apps.enable = true;
        };
  };
}
