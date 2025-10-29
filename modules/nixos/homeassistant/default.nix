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
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
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
