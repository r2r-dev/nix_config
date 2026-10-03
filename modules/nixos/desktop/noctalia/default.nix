{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.desktop.noctalia;
in
{
  options.my.desktop.noctalia = {
    enable = lib.mkEnableOption "the noctalia desktop environment";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
    programs.noctalia = {
      enable = true;

      # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
      recommendedServices.enable = true;
    };
    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        cursor.size = 24;
        keyboard.layout = config.my.keyboard.layout;
        path = "${pkgs.graphite-cursors}/share/icons";
      };
    };
  };
}
