# Home-manager configuration of the primary user on samsara.
{ pkgs, ... }:
{
  home.packages = with pkgs; [ git ];

  # $HOME state kept on the persistent volume that no module covers.
  # (Modules add their own: Plasma, Steam, Firefox, ssh/gpg, XDG dirs, ...)
  my.persist = {
    directories = [
      "Games"
      "Projects"
      ".config/discord" # Discord config/local state.
      #".config/Signal" # Signal config/local state.
      ".local/share/bookeeper" # bg3 mod manager
      ".local/share/direnv"
      ".local/share/keyrings"
      ".nixops"
    ];
    files = [
      ".config/coderv2/session"
      ".config/coderv2/url"
      ".config/monitors.xml"
      "fs-diff.sh"
    ];
  };
}
