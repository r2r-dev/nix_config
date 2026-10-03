{
  config,
  pkgs,
  inputs,
  ...
}:
{
  nixpkgs.overlays = [ inputs.proton-cachyos.overlays.default ];

  imports = [
    inputs.nur.modules.nixos.default
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  my = {
    # core
    boot.enable = true;
    kernel.enable = true;
    locale.enable = true;
    nix.enable = true;
    persist = {
      enable = true;
      rollback.device = "/dev/mapper/pool0n0-decrypted";
    };
    power.neverSleep = true;
    secrets.enable = true;
    ssh.enable = true;
    user = {
      enable = true;
      extraGroups = [
        "wheel"
        "input"
      ];
    };

    hardware = {
      gpu = "nvidia";
      # displaylink left off: broken on 6.18.1-zen-dev
      bluetooth.enable = true;
      fans = {
        enable = true;
        it87.enable = true;
      };
      ios.enable = true;
      rgb.enable = true;
      wol = {
        enable = true;
        interface = "enp14s0";
      };
      xbox.enable = true;
    };

    desktop = {
      plasma.enable = true;
      sound.enable = true;
    };

    gaming = {
      performance = {
        enable = true;
        disableMitigations = true;
      };
      steam.enable = true;
      gamemode.enable = true;
      session = {
        enable = true;
        autoLogin.enable = true;
        width = 3840;
        height = 2160;
        refreshRate = 165;
      };
    };

    services = {
      remotePower.enable = true;
      wolf.enable = true;
      zerotier.puqu.enable = true;
    };
  };

  virtualisation.docker.storageDriver = "btrfs";

  boot.kernelParams = [ "amd_pstate=active" ];

  hardware = {
    enableAllFirmware = true; # ?rgb?
    cpu.amd.updateMicrocode = true;
    # Enable OpenGL
    graphics = {
      enable32Bit = true;
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    nur.repos.xddxdd.uncategorized.vk-hdr-layer
  ];

  home-manager.users.${config.my.user.name} =
    { pkgs, ... }:
    {
      imports = [
        inputs.self.homeManagerModules.r2r
        ./persistence.nix
      ];
      home.packages = with pkgs; [
        git
        nixfmt
      ];
    };

  system.stateVersion = "24.11";
}
