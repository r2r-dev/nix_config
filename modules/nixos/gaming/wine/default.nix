# Wine: running Windows applications outside Steam.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.gaming.wine.enable = lib.mkEnableOption "Wine and winetricks";

  config = lib.mkIf config.my.gaming.wine.enable {
    environment.systemPackages = with pkgs; [
      winetricks
      wineWow64Packages.stable
      wine64
    ];
  };
}
