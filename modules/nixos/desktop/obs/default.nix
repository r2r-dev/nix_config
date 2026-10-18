# obs with the plugins for recording wayland desktop and games
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktop.obs;
in
{
  options.my.desktop.obs = {
    enable = lib.mkEnableOption "OBS Studio";
  };

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs # hyprland screen capture
        obs-pipewire-audio-capture
        obs-vkcapture # vulkan capture
        obs-backgroundremoval
        obs-gstreamer
        obs-vaapi # hardware encoding
      ];
    };
  };
}
