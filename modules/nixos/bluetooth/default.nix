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
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf (cfg.enable) {
    # Enable Bluetooth
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
    environment.persistence."/persist" =
      lib.mkIf config.modules.nixos.impermanence.enable
        {
          directories = [
            "/var/lib/bluetooth"
          ];
        };
  };
}
