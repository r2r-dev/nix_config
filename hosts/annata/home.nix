# Home-manager configuration of the primary user on annata.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    coder
    discord
    openscad-unstable
    plasticity
    proton-vpn
    signal-desktop
    sshx # TODO ssh module
  ];
}
