# Bluetooth: enable Bluetooth with Blueman, and persist pairing state on
# impermanent hosts.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.bluetooth;
in
{
  options.modules.nixos.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support (with Blueman)";
  };

  config = lib.mkIf cfg.enable {
    # Enable Bluetooth
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
    environment.persistence.main =
      lib.mkIf config.modules.nixos.impermanence.enable
        {
          directories = [
            "/var/lib/bluetooth"
          ];
        };
  };
}
