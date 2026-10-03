{
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
    # displaylink left off: broken on 6.18.1-zen-dev
    impermanence.enable = true;
    bluetooth.enable = true;
    boot.enable = true;
    plasma.enable = true;
    wolf = {
      enable = true;
      gpuType = "nvidia";
    };
    remotePower.enable = true;
    kernel.enable = true;
    fans = {
      enable = true;
      it87.enable = true;
    };
    ios.enable = true;
    locale.enable = true;
    noSuspend.enable = true;
    nix.enable = true;
    nvidia.enable = true;
    performance = {
      enable = true;
      disableMitigations = true;
    };
    rgb.enable = true;
    secrets = {
      enable = true;
      sshHostKeyDir = "/persist/etc/ssh";
    };
    sound.enable = true;
    ssh.enable = true;
    steam = {
      enable = true;
      autoLogin.enable = true;
      gamescopeSession = {
        enable = true;
        width = 3840;
        height = 2160;
        refreshRate = 165;
      };
    };
    users = {
      enable = true;
      extraGroups = [
        "wheel"
        "input"
      ];
    };
    xbox.enable = true;
    zerotier = {
      puqu.enable = true;
    };
    wol = {
      enable = true;
      interface = "enp14s0";
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

  home-manager.users.r2r =
    { pkgs, ... }:
    {
      imports = [
        inputs.self.homeManagerModules.r2r
        ./persistence.nix
      ];
      home.packages = with pkgs; [
        git
        nixfmt-rfc-style
      ];
    };

  system.stateVersion = "24.11";
}
