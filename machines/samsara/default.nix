{
  config,
  pkgs,
  outputs,
  ...
}:
{
  imports = with outputs.nixosModules; [
    impermanence
    gow_wolf
    bluetooth
    boot
    desktop
    fans
    kernel
    network
    nix
    nvidia
    prompter
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

  extraServices.gow_wolf.enable = true;
  extraServices.gow_wolf.gpu_type = "nvidia";
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
      home.packages = with pkgs; [
        coder
        python3
        discord
        git
        keepassxc
        nixfmt-rfc-style
        protonvpn-cli
        protonvpn-gui
        signal-desktop
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

  system.stateVersion = "24.11";
}
