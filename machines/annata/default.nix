{
  pkgs,
  config,
  outputs,
  ...
}:
let
  libfprint-focaltech =
    pkgs.callPackage ./fingerprint.nix
      { };
in
{
  imports = with outputs.nixosModules; [
    impermanence
    prompter
    bluetooth
    boot
    gow_wolf
    desktop
    nix
    kernel
    keyboard
    steam
    xbox
    zerotier
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./audio.nix
  ];
  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key"
    ];
    secrets = {
      "r2r.passwd".file = ../../secrets/r2r.passwd.age;
    };
  };

  modules = {
    nixos = {
      impermanence = {
        enable = false;
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
      keyboard = {
        enable = false;
      };
      zerotier = {
        puqu = {
          enable = true;
        };
        warp = {
          enable = true;
        };
      };
    };
  };

  programs = {
    steam = {
      gamescopeSession = {
        enable = true; # Integrates with programs.steam
        args = [
          "-W 2560"
          "-H 1600"
          "-w 2560"
          "-h 1600"
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
    };
  };

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  hardware = {
    ledger.enable = true;
    gpd.pocket4.audioEnhancement.enable = true;
    # Enable interface to sensors like Accelerometers and Light sensors
    sensor.iio.enable = true;
  };
  services = {
    udev.extraHwdb = ''
      # GPD Pocket 4
      sensor:modalias:*
        ACCEL_MOUNT_MATRIX=-1, 0, 0; 0, 1, 0; 1, 0, 0
    '';
    # Enable fprintd
    fprintd = {
      enable = true;
      package = pkgs.fprintd.override {
        libfprint = libfprint-focaltech;
      };
    };
    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
      wireplumber.enable = true;
    };
  };

  networking.hostName = "annata"; # Define your hostname.

  programs = {
    kdeconnect.enable = true;
    coolercontrol.enable = true;
    firefox.enable = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  security.rtkit.enable = true;

  users = {
    mutableUsers = false;
    users = {
      r2r = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets."r2r.passwd".path;
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
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
      home.packages = with pkgs; [
        python3
        discord
        git
        keepassxc
        nixfmt-rfc-style
        protonvpn-cli
        protonvpn-gui
        signal-desktop
        moonlight-qt
        sshx # TODO ssh module
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    flatpak
    gnome-software
    kubectl
    plasticity

    # fans
    coolercontrol.coolercontrold
    coolercontrol.coolercontrol-liqctld
    liquidctl
    lm_sensors # tools and drivers for monitoring temperatures, voltage, and fans
    coder
    vim
    maliit-keyboard
    maliit-framework
  ];

  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
