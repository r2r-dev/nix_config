# Noctalia: Hyprland with the noctalia shell and greeter. The noctalia
# home-manager module is made available to the primary user
# (programs.noctalia in their home config).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.my.desktop.noctalia;

  # aquamarine main (evdi CPU-copy fallback, #279) + GUD USB displays
  aquamarine = pkgs.aquamarine.overrideAttrs (old: {
    version = "0.15.1-unstable-2026-10-30";
    src = pkgs.fetchFromGitHub {
      owner = "hyprwm";
      repo = "aquamarine";
      rev = "eac1b827c4a12dc026f21c966cde2f248fe6ee12";
      hash = "sha256-LKHPWs7mm7/y8Y0urwmYnnGZ00YTCoF/SU/aEEwPi5I=";
    };
    patches = (old.patches or [ ]) ++ [
      ./aquamarine-gud.patch
      ./aquamarine-renderless-cpu-copy.patch
    ];
  });
in
{
  options.my.desktop.noctalia = {
    enable = lib.mkEnableOption "the noctalia desktop environment";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      package = pkgs.hyprland.override { inherit aquamarine; };
    };
    programs.noctalia = {
      enable = true;

      # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
      recommendedServices.enable = true;
    };
    services.displayManager.noctalia-greeter = {
      enable = true;
      passwordlessSyncUsers = [ config.my.user.name ];
      settings = {
        appearance.hide_logo = lib.mkDefault true;
        keyboard.layout = config.my.keyboard.layout;
      };
    };

    # hyprland for screen capture and screenshots
    # gtk for everything else
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      };
    };

    # Terminal used by the Hyprland config; X11 apps under the session.
    environment.systemPackages = with pkgs; [
      ghostty
      xwayland-satellite
    ];

    home-manager.users.${config.my.user.name}.imports = [
      inputs.noctalia.homeModules.default
    ];
  };
}
