{ inputs, ... }:
{
  nixpkgs.overlays = [ inputs.proton-cachyos.overlays.default ];

  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate # microcode + amd_pstate
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
      # 4K gamescope session corrupts without it (see the option).
      nvidia.contiguousVram = true;
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

    desktop = {
      plasma.enable = true;
      remoteApps.enable = true;
    };

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
      wolf.enable = false;
      zerotier.puqu.enable = true;
    };
  };

  hardware.enableAllFirmware = true; # ?rgb?

  boot.kernelParams = [
    "pci=realloc" # enable dynamic pci allocation to handle 14+ usb ports
    # NVMe power saving workaround
    "nvme_core.default_ps_max_latency_us=0"
    "pcie_aspm=off" # disable asynchronous power management
  ];

  system.stateVersion = "24.11";
}
