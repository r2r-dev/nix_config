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
} // lib.mkIf config.r2r.impermanence.enable (
  {
    environment.persistence."/persist" = {
      directories = [
        "/var/lib/bluetooth"
      ];
    };
  })
