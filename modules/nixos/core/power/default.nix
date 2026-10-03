# Power: sleep policy. `neverSleep` disables every form of system sleep
# (for always-on hosts).
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.power;
in
{
  options.my.power = {
    neverSleep = lib.mkEnableOption "disabling all forms of system sleep/suspend";
  };

  config = lib.mkIf cfg.neverSleep {
    systemd.sleep.settings.Sleep = {
      AllowSuspend = false;
      AllowHibernation = false;
      AllowHybridSleep = false;
      AllowSuspendThenHibernate = false;
    };
  };
}
