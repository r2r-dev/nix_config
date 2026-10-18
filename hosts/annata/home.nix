# Home-manager configuration of the primary user on annata.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    coder
    discord
    kubectl
    openscad-unstable
    plasticity
    proton-vpn
    signal-desktop
    waypipe
  ];
}
