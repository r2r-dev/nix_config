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
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf (cfg.enable) {
    # Enable the KDE Plasma Desktop Environment.
    services = {
      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
      xserver.xkb.layout = "pl";
    };
    console.keyMap = "pl2";
  };
}
