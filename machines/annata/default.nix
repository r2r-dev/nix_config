{
  pkgs,
  outputs,
  ...
}:
{
  imports = with outputs.nixosModules; [
    impermanence
    homeassistant
    prompter
    bluetooth
    boot
    gow_wolf
    desktop
    fans
    flatpak
    nix
    kernel
    keyboard
    locale
    network
    printing
    secrets
    sound
    ssh
    steam
    users
    xbox
    zerotier
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./hardware.nix
    ./audio.nix
  ];

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
      fans = {
        enable = true;
      };
      flatpak = {
        enable = true;
      };
      homeassistant = {
        enable = true;
      };
      kernel = {
        enable = true;
      };
      keyboard = {
        enable = false;
      };
      locale = {
        enable = true;
        regional = true;
      };
      network = {
        enable = true;
        hostName = "annata";
      };
      nix = {
        enable = true;
      };
      printing = {
        enable = true;
      };
      prompter = {
        enable = true;
      };
      secrets = {
        enable = true;
      };
      sound = {
        enable = true;
        jack = true;
      };
      ssh = {
        enable = true;
      };
      steam = {
        enable = true;
        gamescopeSession = {
          enable = true;
          width = 2560;
          height = 1600;
        };
      };
      users = {
        enable = true;
      };
      xbox = {
        enable = true;
      };
      zerotier = {
        puqu = {
          enable = false;
        };
        warp = {
          enable = false;
        };
      };
    };
  };

  programs = {
    kdeconnect.enable = true;
    firefox.enable = true;
  };

  home-manager.users.r2r =
    { pkgs, ... }:
    {
      imports = [ outputs.homeManagerModules.r2r ];
      home.packages = with pkgs; [
        discord
        signal-desktop
        moonlight-qt
        nixfmt
        openscad-unstable
        proton-vpn
        sshx # TODO ssh module
        plasticity
        coder
      ];
    };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    flatpak
    git
    gnome-software
    kubectl
    maliit-framework
    maliit-keyboard
    vim
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
