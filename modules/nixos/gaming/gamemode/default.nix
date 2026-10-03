# GameMode: on-demand performance tuning, with the primary user in the
# `gamemode` group and higher resource limits for that group.
#
# GameMode's privileged helpers are authorised by the polkit action and rule
# shipped in the gamemode package (members of the `gamemode` group), so no
# sudo rules or copied policy files are needed here.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.gaming.gamemode;
in
{
  options.my.gaming.gamemode = {
    enable = lib.mkEnableOption "GameMode";
  };

  config = lib.mkIf cfg.enable {
    programs.gamemode = {
      enable = true;
      settings.general.renice = 10;
    };

    users.users.${config.my.user.name}.extraGroups = [ "gamemode" ];

    services.udev.extraRules = ''
      KERNEL=="cpu_dma_latency", GROUP="gamemode"
    '';

    # Higher resource limits. Used by Lutris/Wine.
    security.pam.loginLimits = [
      {
        domain = "@gamemode";
        item = "nofile";
        type = "soft";
        value = "1048576";
      }
      {
        domain = "@gamemode";
        item = "nofile";
        type = "hard";
        value = "1048576";
      }
      {
        domain = "@gamemode";
        type = "-";
        item = "rtprio";
        value = 98;
      }
      {
        domain = "@gamemode";
        type = "-";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "@gamemode";
        type = "-";
        item = "nice";
        value = -11;
      }
    ];
  };
}
