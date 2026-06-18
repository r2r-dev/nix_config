{
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
    ios
    kernel
    locale
    network
    nix
    no_suspend
    nvidia
    #prompter broken on 6.18.1-zen-dev
    rgb
    secrets
    sound
    ssh
    steam
    users
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
      kernel = {
        enable = true;
      };
      fans = {
        enable = true;
        it87.enable = true;
      };
      ios = {
        enable = true;
      };
      locale = {
        enable = true;
      };
      no_suspend = {
        enable = true;
      };
      nix = {
        enable = true;
      };
      nvidia = {
        enable = true;
      };
      rgb = {
        enable = true;
      };
      secrets = {
        enable = true;
        sshHostKeyDir = "/persist/etc/ssh";
      };
      sound = {
        enable = true;
      };
      ssh = {
        enable = true;
      };
      steam = {
        enable = true;
        autoLogin = {
          enable = true;
        };
        gamescopeSession = {
          enable = true;
          width = 3840;
          height = 2160;
        };
      };
      users = {
        enable = true;
        extraGroups = [
          "wheel"
          "input"
        ];
      };
      xbox = {
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

  virtualisation.docker.storageDriver = "btrfs";

  hardware = {
    enableAllFirmware = true; # ?rgb?
    # Enable OpenGL
    graphics = {
      enable32Bit = true;
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    nur.repos.xddxdd.uncategorized.vk-hdr-layer
  ];

  home-manager.users.r2r =
    { pkgs, ... }:
    {
      imports = [
        outputs.homeManagerModules.r2r
        ./persistence.nix
      ];
      home.packages = with pkgs; [
        git
        nixfmt-rfc-style
      ];
    };

  system.stateVersion = "24.11";
}
