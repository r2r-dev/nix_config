# Home-manager configuration of the primary user on annata.
{ inputs, pkgs, ... }:
{
  imports = [ inputs.noctalia.homeModules.default ];

  home.packages = with pkgs; [
    coder
    discord
    openscad-unstable
    plasticity
    proton-vpn
    signal-desktop
    sshx # TODO ssh module
  ];

  home.pointerCursor = {
    enable = true;
    package = pkgs.graphite-cursors;
    name = "graphite-light";
    size = 24;
    gtk.enable = true; # GTK apps
    x11.enable = true; # XWayland apps
    hyprcursor.enable = true; # Hyprland
  };
}
