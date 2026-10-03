# Bluetooth: enable Bluetooth with Blueman, and persist pairing state on
# impermanent hosts.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.bluetooth;
in
{
  options.my.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support (with Blueman)";
  };

  config = lib.mkIf cfg.enable {
    # Enable Bluetooth
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
    my.persist = {
      directories = [
        "/var/lib/bluetooth"
      ];
    };
  };
}
