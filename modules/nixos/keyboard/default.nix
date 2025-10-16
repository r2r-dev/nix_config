{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hardware.keyd;
in
{
  options.hardware.keyd = with types; {
    enable = mkEnableOption "Enable keyd";
  };

  config = mkIf cfg.enable {
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
