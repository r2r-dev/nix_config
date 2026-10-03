{
  config,
  pkgs,
  inputs,
  ...
}:
{
  nixpkgs.overlays = [ inputs.proton-cachyos.overlays.default ];

  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate # microcode + amd_pstate
    inputs.nur.modules.nixos.default
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  my = {
    profiles = {
      workstation.enable = true;
      gaming.enable = true;
    };

    persist = {
      enable = true;
      rollback.device = "/dev/mapper/pool0n0-decrypted";
    };
    power.neverSleep = true;
    user.extraGroups = [
      "wheel"
      "input"
    ];

    hardware = {
      gpu = "nvidia";
      # displaylink left off: broken on 6.18.1-zen-dev
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
    };

    desktop.plasma.enable = true;

    gaming = {
      performance = {
        enable = true;
        disableMitigations = true;
      };
      session = {
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

  hardware.enableAllFirmware = true; # ?rgb?

  environment.systemPackages = with pkgs; [
    nur.repos.xddxdd.uncategorized.vk-hdr-layer
  ];

  home-manager.users.${config.my.user.name} = ./home.nix;

  system.stateVersion = "24.11";
}
