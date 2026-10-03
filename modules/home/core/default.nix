# Core: always-on basics for every home-manager user.
{ lib, ... }:
{
  programs.bash.enable = true;

  # The state version is required and should stay at the version you
  # originally installed. Hosts can override it.
  home.stateVersion = lib.mkDefault "24.11";
}
