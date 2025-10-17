{
  config,
  lib,
  ...
}:
{
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
}
