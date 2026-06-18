# Steam: Steam with gamescope, gamemode, and the GameMode polkit/limits
# plumbing. Optionally boots straight into a gamescope Steam session.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixos.steam;
  gs = cfg.gamescopeSession;
  auto = cfg.autoLogin;
in
{
  options.modules.nixos.steam = {
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
        gamemode
        gamescope
        gamescope-wsi
        mangohud
        moonlight-qt
        steamtinkerlaunch
        gamescope
        gamescope-wsi
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
      sudo = {
        extraRules = [
          {
            groups = [
              "gamemode"
            ];
            commands = [
              {
                command = "${pkgs.gamemode}/bin/gamemoderun";
                options = [ "NOPASSWD" ];
              }
              {
                command = "${pkgs.gamemode}/libexec/procsysctl";
                options = [ "NOPASSWD" ];
              }
              {
                command = "${pkgs.gamemode}/libexec/cpugovctl";
                options = [ "NOPASSWD" ];
              }
              {
                command = "${pkgs.gamemode}/libexec/gpuclockctl";
                options = [ "NOPASSWD" ];
              }
              {
                command = "^/nix/store/.*/bin/gamemoderun$";
                options = [ "NOPASSWD" ];
              }
              {
                command = "^/nix/store/.*/libexec/procsysctl$";
                options = [ "NOPASSWD" ];
              }
              {
                command = "^/nix/store/.*/libexec/cpugovctl$";
                options = [ "NOPASSWD" ];
              }
              {
                command = "^/nix/store/.*/libexec/gpuclockctl$";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];
      };

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
    security.polkit.extraConfig = ''
      polkit.addRule(function (action, subject) {
        if ((action.id == "com.feralinteractive.GameMode.governor-helper" ||
          action.id == "com.feralinteractive.GameMode.gpu-helper" ||
          action.id == "com.feralinteractive.GameMode.cpu-helper" ||
          action.id == "com.feralinteractive.GameMode.procsys-helper") &&
          subject.isInGroup("gamemode"))
        {
          return polkit.Result.YES;
        }
      });
    '';

    environment.etc."polkit-1/actions/com.feralinteractive.GameMode.policy".text =
      ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE policyconfig PUBLIC
         "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
         "http://www.freedesktop.org/standards/PolicyKit/1.0/policyconfig.dtd">
        <policyconfig>

          <!--
            Copyright (c) 2017-2019, Feral Interactive
            All rights reserved.
          -->

          <vendor>Feral GameMode Activation</vendor>
          <vendor_url>http://www.feralinteractive.com</vendor_url>

          <action id="com.feralinteractive.GameMode.governor-helper">
            <description>Modify the CPU governor</description>
            <message>Authentication is required to modify the CPU governor</message>
            <defaults>
              <allow_any>no</allow_any>
              <allow_inactive>no</allow_inactive>
              <allow_active>no</allow_active>
            </defaults>
            <annotate key="org.freedesktop.policykit.exec.path">${pkgs.gamemode}/libexec/cpugovctl</annotate>
          </action>

          <action id="com.feralinteractive.GameMode.gpu-helper">
            <description>Modify the GPU clock states</description>
            <message>Authentication is required to modify the GPU clock states</message>
            <defaults>
              <allow_any>no</allow_any>
              <allow_inactive>no</allow_inactive>
              <allow_active>no</allow_active>
            </defaults>
            <annotate key="org.freedesktop.policykit.exec.path">${pkgs.gamemode}/libexec/gpuclockctl</annotate>
            <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
          </action>

          <action id="com.feralinteractive.GameMode.cpu-helper">
            <description>Modify the CPU core states</description>
            <message>Authentication is required to modify the CPU core states</message>
            <defaults>
              <allow_any>no</allow_any>
              <allow_inactive>no</allow_inactive>
              <allow_active>no</allow_active>
            </defaults>
            <annotate key="org.freedesktop.policykit.exec.path">${pkgs.gamemode}/libexec/cpucorectl</annotate>
            <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
          </action>

          <action id="com.feralinteractive.GameMode.procsys-helper">
            <description>Modify the /proc/sys values</description>
            <message>Authentication is required to modify the /proc/sys/ values</message>
            <defaults>
              <allow_any>no</allow_any>
              <allow_inactive>no</allow_inactive>
              <allow_active>no</allow_active>
            </defaults>
            <annotate key="org.freedesktop.policykit.exec.path">${pkgs.gamemode}/libexec/procsysctl</annotate>
            <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
          </action>
        </policyconfig>
      '';
  };
}
