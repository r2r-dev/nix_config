# Flatpak: Flatpak with the Flathub remote and the apps declared in
# `my.desktop.flatpak.packages`, managed by nix-flatpak (installed on
# activation, optionally kept up to date weekly).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.desktop.flatpak;
in
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  options.my.desktop.flatpak = {
    enable = lib.mkEnableOption "Flatpak with the Flathub remote";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "com.github.tchx84.Flatseal"
        "org.videolan.VLC"
      ];
      description = ''
        Flathub app IDs to install system-wide. Apps installed by hand
        (GNOME Software, `flatpak install`) are left alone unless
        `pruneUnmanaged` is set.
      '';
    };

    pruneUnmanaged = lib.mkEnableOption ''
      removing Flatpak apps and remotes that are not declared here
    '';

    autoUpdate = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Update the declared apps weekly (and at activation).";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    services.flatpak = {
      enable = true;
      # Flathub is nix-flatpak's default remote.
      inherit (cfg) packages;
      uninstallUnmanaged = cfg.pruneUnmanaged;
      update = {
        onActivation = cfg.autoUpdate;
        auto = {
          enable = cfg.autoUpdate;
          onCalendar = "weekly";
        };
      };
    };

    # Graphical store for browsing and installing Flathub apps.
    environment.systemPackages = [ pkgs.gnome-software ];

    # Installed apps and runtimes.
    my.persist.directories = [ "/var/lib/flatpak" ];
  };
}
