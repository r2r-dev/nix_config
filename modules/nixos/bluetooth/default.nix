{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
  environment.persistence."/persist" = lib.mkIf (config.r2r.impermanence.enable) {
    directories = [
      "/var/lib/bluetooth"
    ];
  };
}
