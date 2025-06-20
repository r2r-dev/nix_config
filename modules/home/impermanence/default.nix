{
  home.persistence."/persist/home/r2r" = {
    directories = [
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      "Projects"
      ".gnupg"
      ".ssh"
      ".nixops"
      ".local/share/keyrings"
      ".local/state/wireplumber" # audio settings
      ".local/share/direnv"
      {
        directory = ".steam";
        method = "symlink";
      }
      {
        directory = ".local/share/Steam";
        method = "symlink";
      }

      # XDG config home directories.
      ".config/discord" # Discord config/local state.
      #".config/Signal" # Signal config/local state.
      # XXX: Is this really necessary to persist?
      ".cache/mozilla" # Firefox local cache.
      ".mozilla" # Firefox config/local state.
    ];
    files = [
      ".config/coderv2/session"
      ".config/coderv2/url"
      ".config/OpenRGB/OpenRGB.json"
      ".config/monitors.xml"
      "fs-diff.sh"
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
      ".config/pulse/cookie"
      ".config/systemsettingsrc"
      ".config/Trolltech.conf"
      #".config/user-dirs.dirs"
      ".config/user-dirs.locale"
      #".config/xsettingsd/xsettingsd.conf"
    ];
    allowOther = true;
  };
}
