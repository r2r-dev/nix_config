# Apps: graphical applications used on every workstation.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.apps.enable = lib.mkEnableOption "the common desktop applications";

  config = lib.mkIf config.my.apps.enable {
    programs.firefox = {
      enable = true;
      # Keep the legacy profile location (~/.mozilla/firefox) rather than the
      # new XDG default, to avoid relocating the existing on-disk profile.
      configPath = ".mozilla/firefox";
    };
    home.packages = with pkgs; [
      eden
      keepassxc
    ];
  };
}
