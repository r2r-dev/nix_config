# Boot: quiet, themed systemd-boot setup with a Plymouth splash.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixos.boot;
in
{
  options.modules.nixos.boot = {
    enable = lib.mkEnableOption "the quiet systemd-boot + Plymouth boot setup";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      loader = {
        # Hide the OS choice for bootloaders.
        # It's still possible to open the bootloader list by pressing any key
        # It will just not appear on screen unless a key is pressed
        timeout = 0;
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
          # By default we would install all themes
          (adi1090x-plymouth-themes.override {
            selected_themes = [ "deus_ex" ];
          })
        ];
      };

      # Enable "Silent Boot"
      consoleLogLevel = 0;

      initrd.verbose = false;
    };
  };
}
