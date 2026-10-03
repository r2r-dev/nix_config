# Plasma: KDE Plasma 6 with SDDM (keyboard layout comes from my.keyboard).
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktop.plasma;
in
{
  options.my.desktop.plasma = {
    enable = lib.mkEnableOption "the KDE Plasma desktop environment";
  };

  config = lib.mkIf cfg.enable {
    # Enable the KDE Plasma Desktop Environment.
    services = {
      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
    };
  };
}
