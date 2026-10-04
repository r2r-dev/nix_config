{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.gpd-pocket-4
    inputs.nix-flatpak.nixosModules.nix-flatpak
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  my = {
    profiles = {
      workstation.enable = true;
      gaming.enable = true;
    };

    locale.regional = true;
    network.enable = true;

    hardware = {
      gpu = "amd";
      gpdPocket4.enable = true;
      displaylink.enable = true;
      fans.enable = true;
    };

    desktop = {
      noctalia.enable = true;
      cursor.enable = true;
      flatpak.enable = true;
      printing.enable = true;
      sound.jack = true;
    };

    gaming.session = {
      width = 2560;
      height = 1600;
    };

    services.remotePower.enable = true;
  };

  programs.kdeconnect.enable = true;
  hardware.ledger.enable = true;

  home-manager.users.${config.my.user.name} = ./home.nix;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    gnome-software
    kubectl
    vim
    winetricks
    wineWow64Packages.stable
    wine64
    waypipe
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
