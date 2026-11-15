# Boot: quiet, themed systemd-boot setup with a Plymouth splash.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.boot;
in
{
  options.my.boot = {
    enable = lib.mkEnableOption "the quiet systemd-boot + Plymouth boot setup";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      loader = {
        timeout = 0; # menu only on keypress
        efi = {
          canTouchEfiVariables = true;
        };

        systemd-boot = {
          enable = true;
          configurationLimit = 20;
        };
      };

      kernelParams = [
        "quiet"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];

      plymouth = {
        enable = true;
        theme = "deus_ex";
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override {
            selected_themes = [ "deus_ex" ];
          })
        ];
      };

      consoleLogLevel = 0;

      initrd.verbose = false;
    };
  };
}
