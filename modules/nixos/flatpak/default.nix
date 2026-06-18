# Flatpak: enable Flatpak and register the Flathub remote at boot.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixos.flatpak;
in
{
  options.modules.nixos.flatpak = {
    enable = lib.mkEnableOption "Flatpak with the Flathub remote";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
