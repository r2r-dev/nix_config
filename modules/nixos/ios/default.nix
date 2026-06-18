# iOS: usbmuxd + libimobiledevice for tethering and file access with
# iPhones/iPads over USB.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixos.ios;
in
{
  options.modules.nixos.ios = {
    enable = lib.mkEnableOption "iOS device tethering and file access";
  };

  config = lib.mkIf cfg.enable {
    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
    environment.systemPackages = [ pkgs.libimobiledevice ];
  };
}
