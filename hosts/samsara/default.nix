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
    hardware.gpu = "nvidia";
    # displaylink left off: broken on 6.18.1-zen-dev
    persist = {
      enable = true;
      rollback.device = "/dev/mapper/pool0n0-decrypted";
    };
    bluetooth.enable = true;
    boot.enable = true;
    plasma.enable = true;
    wolf.enable = true;
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
    performance = {
      enable = true;
      disableMitigations = true;
    };
    rgb.enable = true;
    secrets.enable = true;
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
    user = {
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
