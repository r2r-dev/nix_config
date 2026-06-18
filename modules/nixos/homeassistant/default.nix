# Home Assistant: a dedicated homeassistant user allowed to power the host
# off/reboot over SSH (for use as a Home Assistant switch).
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.homeassistant;
in
{
  options.modules.nixos.homeassistant = {
    enable = lib.mkEnableOption "the Home Assistant power-control user";
  };

  config = lib.mkIf cfg.enable {
    users.groups.homeassistant = { };
    users.users.homeassistant = {
      group = "homeassistant";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFjrl7ckZi0+SicEhO64c+hwxsJxQDlR+n5zWeKpVfZ hassio@ha.warp.r2r.sh-ssh"
      ];
    };

    security.sudo = {
      enable = true;
      extraRules = [
        {
          commands = [
            {
              command = "/run/current-system/sw/bin/shutdown";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/poweroff";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/reboot";
              options = [ "NOPASSWD" ];
            }
          ];
          groups = [ "homeassistant" ];
        }
      ];
    };
  };
}
