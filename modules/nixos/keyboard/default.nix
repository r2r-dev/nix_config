# Keyboard: keyd-based key remapping (remaps are currently commented out).
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.keyboard;
in
{
  options.modules.nixos.keyboard = {
    enable = lib.mkEnableOption "keyd key remapping";
  };

  config = lib.mkIf cfg.enable {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings.main = {
          #capslock = "overload(control, esc)";
          #esc = "capslock";
          #shift = "oneshot(shift)";
          #leftalt = "oneshot(altgr)";
          #rightalt = "oneshot(altgr)";
        };
      };
    };
  };
}
