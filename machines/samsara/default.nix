{
  config,
  pkgs,
  outputs,
  ...
}:
{
  imports = with outputs.nixosModules; [
    impermanence
    homeassistant
    gow_wolf
    bluetooth
    boot
    desktop
    fans
    kernel
    network
    nix
    nvidia
    #prompter broken on 6.18.1-zen-dev
    rgb
    sound
    ssh
    steam
    xbox
    zerotier
    wol

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  modules = {
    nixos = {
      impermanence = {
        enable = true;
      };
      bluetooth = {
        enable = true;
      };
      boot = {
        enable = true;
      };
      desktop = {
        enable = true;
      };
      gow_wolf = {
        enable = true;
        gpu_type = "nvidia";
      };
      homeassistant = {
        enable = true;
      };
      fans = {
        enable = true;
      };
      zerotier = {
        puqu = {
          enable = true;
        };
      };
      wol = {
        enable = true;
        interface = "enp14s0";
      };
    };
  };

  programs.eden = {
    enable = true;
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';


  virtualisation.docker.storageDriver = "btrfs";

  programs.steam.gamescopeSession = {
    enable = true; # Integrates with programs.steam
    args = [
      "-W 3840"
      "-H 2160"
      "-w 3840"
      "-h 2160"
      "--fullscreen"
      "--steam"
      "-r 120"
      "--xwayland-count 2"
      "--adaptive-sync"
      "--hdr-enabled"
      "--hdr-itm-enabled"
      "--mangoapp"
    ];
    steamArgs = [
      "-pipewire-dmabuf"
      "-gamepadui"
      "-steamos3"
    ];
  };

  services.getty.autologinUser = "r2r";
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "r2r";
    };
    defaultSession = pkgs.lib.mkForce "steam";
  };

  age = {
    identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/persist/etc/ssh/ssh_host_rsa_key"
    ];
    secrets = {
      "r2r.passwd".file = ../../secrets/r2r.passwd.age;
    };
  };

  hardware = {
    enableAllFirmware = true; # ?rgb?
  };

  time.timeZone = "Europe/Warsaw";

  # enable ios tethering
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  environment.systemPackages = with pkgs; [
    nur.repos.xddxdd.uncategorized.vk-hdr-layer
    libimobiledevice
  ];

  # Enable OpenGL
  hardware.graphics = {
    enable32Bit = true;
    enable = true;
  };

  users = {
    mutableUsers = false;
    users = {
      r2r = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets."r2r.passwd".path;
        extraGroups = [
          "wheel"
          "input"
        ]; # Enable ‘sudo’ for the user.
      };
    };
  };

  home-manager.users.r2r =
    { pkgs, ... }:
    {
      nixpkgs = {
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };
      nix = {
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };
      home.persistence."/persist" = {
        directories = [
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"
          "Projects"
          "Games"
          ".local/share/eden"
          ".config/eden"
          ".gnupg"
          ".ssh"
          ".nixops"
          ".local/share/keyrings"
          ".local/state/wireplumber" # audio settings
          ".local/share/direnv"
          ".local/share/bookeeper" # bg3 mod manager
          {
            directory = ".steam";
          }
          {
            directory = ".local/share/Steam";
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
      };
      home.packages = with pkgs; [
        python3
        git
        keepassxc
        nixfmt-rfc-style
        sshfs # TODO ssh module
      ];
      programs = {
        bash.enable = true;
        firefox.enable = true;
        vim.enable = true;
      };

      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "24.11";
    };

  system.stateVersion = "24.11";
}
