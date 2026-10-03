# Steam: Steam with gamescope, gamemode and gaming resource limits.
# Optionally boots straight into a gamescope Steam session.
#
# GameMode's privileged helpers are authorised by the polkit action and rule
# shipped in the gamemode package (members of the `gamemode` group), so no
# sudo rules or copied policy files are needed here.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.steam;
  gs = cfg.gamescopeSession;
  auto = cfg.autoLogin;
in
{
  options.my.steam = {
    enable = lib.mkEnableOption "Steam with gamescope and gamemode";
    autoLogin = {
      enable = lib.mkEnableOption "automatic login straight into the Steam session";
      user = lib.mkOption {
        type = lib.types.str;
        default = "r2r";
        description = "User to automatically log in as.";
      };
    };
    gamescopeSession = {
      enable = lib.mkEnableOption "the gamescope Steam session";
      width = lib.mkOption {
        type = lib.types.int;
        default = 1920;
        description = "Horizontal output resolution for the gamescope session.";
      };
      height = lib.mkOption {
        type = lib.types.int;
        default = 1080;
        description = "Vertical output resolution for the gamescope session.";
      };
      refreshRate = lib.mkOption {
        type = lib.types.int;
        default = 120;
        description = "Refresh rate (Hz) for the gamescope session.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.r2r = {
      extraGroups = [ "gamemode" ];
      packages = with pkgs; [
        bottles
        gamescope
        gamescope-wsi
        mangohud
        moonlight-qt
        steamtinkerlaunch
        #lutris # blocked by https://github.com/NixOS/nixpkgs/pull/454074
        vulkan-tools
      ];
    };

    services = {
      getty.autologinUser = lib.mkIf auto.enable auto.user;
      displayManager = lib.mkIf auto.enable {
        autoLogin = {
          enable = true;
          user = auto.user;
        };
        defaultSession = lib.mkForce "steam";
      };

      sunshine = {
        enable = false;
        autoStart = false;
        capSysAdmin = true;
        openFirewall = true;
      };

      ananicy = {
        # https://github.com/NixOS/nixpkgs/issues/351516
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
    };

    programs = {
      gamescope = {
        enable = true;
        capSysNice = false; # https://github.com/NixOS/nixpkgs/issues/523427
      };
      gamemode = {
        enable = true;
        settings = {
          general = {
            renice = 10;
          };
        };
      };
      steam = {
        enable = true;
        protontricks.enable = true;
        gamescopeSession = lib.mkIf gs.enable {
          enable = true; # Integrates with programs.steam
          args = [
            "-W ${toString gs.width}"
            "-H ${toString gs.height}"
            "-w ${toString gs.width}"
            "-h ${toString gs.height}"
            "--fullscreen"
            "--steam"
            "-r ${toString gs.refreshRate}"
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

    boot = {
      kernel.sysctl = {
        # SteamOS/Fedora default, can help with performance.
        "vm.max_map_count" = 2147483642;
      };

    };

    services.udev.extraRules = ''
      KERNEL=="cpu_dma_latency", GROUP="gamemode"
    '';
    security = {
      pam = {
        # Higher resource limits. Used by Lutris/Wine.
        loginLimits = [
          {
            domain = "@gamemode";
            item = "nofile";
            type = "soft";
            value = "1048576";
          }
          {
            domain = "@gamemode";
            item = "nofile";
            type = "hard";
            value = "1048576";
          }
          {
            domain = "@gamemode";
            type = "-";
            item = "rtprio";
            value = 98;
          }
          {
            domain = "@gamemode";
            type = "-";
            item = "memlock";
            value = "unlimited";
          }
          {
            domain = "@gamemode";
            type = "-";
            item = "nice";
            value = -11;
          }
        ];
      };
    };
  };
}
