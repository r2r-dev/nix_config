{
  config,
  pkgs,
  ...
}:

{
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "xbox-one-elite-2-udev-rules";
      text = ''KERNEL=="hidraw*", TAG+="uaccess"'';
      destination = "/etc/udev/rules.d/60-xbox-elite-2-hid.rules";
    })
  ];
  hardware.xpadneo.enable = true; # Enable the xpadneo driver for Xbox One wireless controllers
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      xpadneo # xbox
    ];
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    ''; # connect xbox controller
    kernelModules = [
      "hid_microsoft" # Xbox One Elite 2 controller driver preferred by Steam
    ];
  };
  hardware.bluetooth.settings.General = {
    experimental = true; # show battery

    # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
    # for pairing bluetooth controller
    Privacy = "device";
    JustWorksRepairing = "always";
    Class = "0x000100";
    FastConnectable = true;
  };
}
