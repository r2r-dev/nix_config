# Plasma: KDE Plasma 6 with SDDM (keyboard layout comes from my.keyboard).
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktop.plasma;
in
{
  options.my.desktop.plasma = {
    enable = lib.mkEnableOption "the KDE Plasma desktop environment";
  };

  config = lib.mkIf cfg.enable {
    # Enable the KDE Plasma Desktop Environment.
    services = {
      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
    };

    # Plasma (and the GTK settings it writes) keep their configuration in
    # these files; keep them on impermanent hosts.
    home-manager.users.${config.my.user.name}.my.persist.files =
      lib.mkIf config.my.persist.enable
        [
          ".config/baloofilerc"
          #".config/dconf/user"
          ".config/gtk-3.0/colors.css"
          #".config/gtk-3.0/gtk.css"
          ".config/gtk-3.0/settings.ini"
          ".config/gtk-4.0/colors.css"
          #".config/gtk-4.0/gtk.css"
          ".config/gtk-4.0/settings.ini"
          ".config/gtkrc"
          ".config/gtkrc-2.0"
          ".config/kactivitymanagerdrc"
          ".config/kactivitymanagerd-statsrc"
          ".config/kconf_updaterc"
          ".config/kded5rc"
          ".config/kdedefaults/kcminputrc"
          ".config/kdedefaults/kdeglobals"
          ".config/kdedefaults/ksplashrc"
          ".config/kdedefaults/kwinrc"
          ".config/kdedefaults/package"
          ".config/kdedefaults/plasmarc"
          ".config/kdeglobals"
          ".config/kde.org/UserFeedback.org.kde.plasmashell.conf"
          ".config/kglobalshortcutsrc"
          ".config/konsolerc"
          ".config/kcminputrc" # touchscreen config
          ".config/ktimezonedrc"
          ".config/kwinoutputconfig.json"
          ".config/kwinrc"
          ".config/plasma-localerc"
          ".config/plasma-org.kde.plasma.desktop-appletsrc"
          ".config/plasmashellrc"
          ".config/powermanagementprofilesrc"
          ".config/systemsettingsrc"
          ".config/Trolltech.conf"
          #".config/xsettingsd/xsettingsd.conf"
        ];
  };
}
