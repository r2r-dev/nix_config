# Desktop: KDE Plasma 6 with SDDM and a Polish keyboard layout.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.desktop;
in
{
  options.modules.nixos.desktop = {
    enable = lib.mkEnableOption "the KDE Plasma desktop environment";
  };

  config = lib.mkIf cfg.enable {
    # Enable the KDE Plasma Desktop Environment.
    services = {
      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
      xserver.xkb.layout = "pl";
    };
    console.keyMap = "pl2";
  };
}
