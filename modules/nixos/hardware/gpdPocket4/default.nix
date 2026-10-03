# GPD Pocket 4: device quirks on top of nixos-hardware's gpd-pocket-4
# module (which the host imports itself):
# - speaker DSP filter chain (./audio.nix)
# - accelerometer mount matrix + iio sensors, and an `autorotate` helper
#   for Hyprland
# - portrait panel rotation for the noctalia greeter
# - on-screen keyboards
# - optional FocalTech fingerprint reader
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.gpdPocket4;
in
{
  imports = [ ./audio.nix ];

  options.my.hardware.gpdPocket4 = {
    enable = lib.mkEnableOption "GPD Pocket 4 device support";
    fingerprint.enable = lib.mkEnableOption ''
      fprintd with the proprietary FocalTech driver (libfprint-focaltech)
    '';
  };

  config = lib.mkIf cfg.enable {
    hardware = {
      gpd.pocket4.audioEnhancement.enable = true;
      # Enable interface to sensors like Accelerometers and Light sensors
      sensor.iio.enable = true;
    };

    services.udev.extraHwdb = ''
      # GPD Pocket 4
      sensor:modalias:acpi:MXC6655*:dmi:*:svnGPD:pnG1628-04:*
       ACCEL_MOUNT_MATRIX=-1, 0, 0; 0, 1, 0; 0, 0, 1
    '';

    services.fprintd = {
      enable = cfg.fingerprint.enable;
      package = pkgs.fprintd.override {
        libfprint = pkgs.libfprint-focaltech;
      };
    };

    # The panel is mounted in portrait.
    services.displayManager.noctalia-greeter.settings.output.transforms =
      lib.mkIf config.services.displayManager.noctalia-greeter.enable "eDP-1:270";

    # On-screen keyboards.
    environment.systemPackages = with pkgs; [
      maliit-framework
      maliit-keyboard
    ];

    home-manager.users.${config.my.user.name}.home.packages =
      with pkgs;
      [ wvkbd ]
      ++ lib.optional config.programs.hyprland.enable (
        # Follow the accelerometer; laptop_orientation is defined in the
        # user's Hyprland config.
        writeShellScriptBin "autorotate" ''
          ${pkgs.iio-sensor-proxy}/bin/monitor-sensor 2>/dev/null | while read -r line; do
            o=$(echo "$line" | grep -oE 'normal|bottom-up|left-up|right-up' | head -1)
            [ -n "$o" ] && hyprctl eval "laptop_orientation(\"$o\")" >/dev/null
          done
        ''
      );
  };
}
