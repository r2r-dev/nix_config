# Session: a SteamOS-like gamescope session running Steam's gamepad UI,
# optionally logged into automatically at boot.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.gaming.session;

  # stop/start the auto-logged-in session (display manager)
  steam-session = pkgs.writeShellApplication {
    name = "steam-session";
    text = ''
      case "''${1:-}" in
        stop | start | status) exec systemctl "$1" display-manager.service ;;
        *)
          echo "usage: steam-session stop|start|status" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  imports = [ inputs.nur.modules.nixos.default ];

  options.my.gaming.session = {
    enable = lib.mkEnableOption "the gamescope Steam session";
    autoLogin = {
      enable = lib.mkEnableOption "automatic login straight into the Steam session";
      user = lib.mkOption {
        type = lib.types.str;
        default = config.my.user.name;
        defaultText = lib.literalExpression "config.my.user.name";
        description = "User to automatically log in as.";
      };
    };
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
    hdr = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable HDR output (and inverse tone mapping for SDR content).";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.my.gaming.steam.enable;
        message = "my.gaming.session requires my.gaming.steam.";
      }
    ];

    # make vulkan games output hdr through gamescope on nvidia
    # where wayland path does not expose it
    environment.systemPackages =
      lib.optional (
        cfg.hdr && config.my.hardware.gpu == "nvidia"
      ) pkgs.nur.repos.xddxdd.uncategorized.vk-hdr-layer
      ++ lib.optional cfg.autoLogin.enable steam-session;

    programs.steam.gamescopeSession = {
      enable = true; # Integrates with programs.steam
      args = [
        "-W ${toString cfg.width}"
        "-H ${toString cfg.height}"
        "-w ${toString cfg.width}"
        "-h ${toString cfg.height}"
        "--fullscreen"
        "--steam"
        "-r ${toString cfg.refreshRate}"
        "--xwayland-count 2"
        "--adaptive-sync"
      ]
      ++ lib.optionals cfg.hdr [
        "--hdr-enabled"
        "--hdr-itm-enabled"
      ]
      ++ [ "--mangoapp" ];
      steamArgs = [
        "-pipewire-dmabuf"
        "-gamepadui"
        "-steamos3"
      ];
    };

    services = lib.mkIf cfg.autoLogin.enable {
      getty.autologinUser = cfg.autoLogin.user;
      displayManager = {
        autoLogin = {
          enable = true;
          user = cfg.autoLogin.user;
        };
        defaultSession = lib.mkForce "steam";
      };
    };

    security.polkit.extraConfig = lib.mkIf cfg.autoLogin.enable ''
      polkit.addRule(function (action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "display-manager.service" &&
            subject.user == "${cfg.autoLogin.user}") {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
