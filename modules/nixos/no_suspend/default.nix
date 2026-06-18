# No-suspend: disable every form of system sleep (for always-on hosts).
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.no_suspend;
in
{
  options.modules.nixos.no_suspend = {
    enable = lib.mkEnableOption "disabling all forms of system sleep/suspend";
  };

  config = lib.mkIf cfg.enable {
    systemd.sleep.settings.Sleep = {
      AllowSuspend = false;
      AllowHibernation = false;
      AllowHybridSleep = false;
      AllowSuspendThenHibernate = false;
    };
  };
}
