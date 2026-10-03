# Home-manager configuration of the primary user on samsara.
{ pkgs, ... }:
{
  imports = [ ./persistence.nix ];

  home.packages = with pkgs; [ git ];
}
