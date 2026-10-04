# Core: always-on basics for every home-manager user.
{ lib, ... }:
{
  programs.bash.enable = true;

  my.persist = {
    directories = [
      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Videos"
    ];
    files = [
      #".config/user-dirs.dirs"
      ".config/user-dirs.locale"
    ];
  };

  # The state version is required and should stay at the version you
  # originally installed. Hosts can override it.
  home.stateVersion = lib.mkDefault "24.11";
}
