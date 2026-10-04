# Steam: the Steam client (with Proton-CachyOS and protontricks), gamescope,
# and the gaming tools installed for the primary user.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.gaming.steam;
in
{
  options.my.gaming.steam = {
    enable = lib.mkEnableOption "Steam with gamescope";
  };

  config = lib.mkIf cfg.enable {
    users.users.${config.my.user.name}.packages = with pkgs; [
      bottles
      gamescope
      gamescope-wsi
      mangohud
      moonlight-qt
      steamtinkerlaunch
      #lutris # blocked by https://github.com/NixOS/nixpkgs/pull/454074
      vulkan-tools
    ];

    # Steam installs games and its runtime into $HOME.
    home-manager.users.${config.my.user.name}.my.persist.directories =
      lib.mkIf config.my.persist.enable
        [
          { directory = ".steam"; }
          { directory = ".local/share/Steam"; }
        ];

    # https://github.com/NixOS/nixpkgs/issues/351516
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-cpp;
      extraRules = [
        {
          "name" = "gamescope";
          "nice" = -20;
        }
      ];
    };

    programs = {
      gamescope = {
        enable = true;
        capSysNice = false; # https://github.com/NixOS/nixpkgs/issues/523427
      };
      steam = {
        enable = true;
        protontricks.enable = true;
        extraPackages =
          with pkgs;
          [
            (writeScriptBin "steamos-session-select" ''
              #!${pkgs.stdenv.shell}
              pkill -f gamescope
            '')
            gamemode
            keyutils
            libkrb5
            libpng
            libpulseaudio
            libvorbis
            libxcb
            libXcursor
            libXi
            libXinerama
            libXScrnSaver
            procps
            stdenv.cc.cc.lib
            usbutils
          ]
          ++ config.fonts.packages;
        extraCompatPackages = with pkgs; [
          proton-cachyos
          steamtinkerlaunch
        ];
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      };
      java.enable = true;
    };

    # SteamOS/Fedora default, can help with performance.
    boot.kernel.sysctl."vm.max_map_count" = 2147483642;
  };
}
