_:

{
  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
  # TODO: if impermanent
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/bluetooth"
    ];
  };
}
