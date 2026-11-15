# Xbox: Xbox One / Elite 2 controller support (xpadneo + Bluetooth tweaks).
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.hardware.xbox;
in
{
  options.my.hardware.xbox = {
    enable = lib.mkEnableOption "Xbox controller support";
  };

  config = lib.mkIf cfg.enable {
    hardware.xpadneo.enable = true; # wireless pads
    boot = {
      kernelModules = [
        "hid_microsoft" # Elite 2, preferred by Steam
      ];
    };
    # Only relevant for wireless controllers; leaves BlueZ alone otherwise.
    hardware.bluetooth.settings.General =
      lib.mkIf config.hardware.bluetooth.enable
        {
          experimental = true; # show battery

          # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
          # for pairing bluetooth controller
          Privacy = "device";
          JustWorksRepairing = "always";
          Class = "0x000100";
          FastConnectable = true;
        };
  };
}
