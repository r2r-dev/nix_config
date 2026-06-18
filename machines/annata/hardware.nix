# GPD Pocket 4 specific hardware quirks.
{ pkgs, ... }:
let
  libfprint-focaltech =
    pkgs.callPackage ./fingerprint.nix
      { };
in
{
  hardware = {
    ledger.enable = true;
    gpd.pocket4.audioEnhancement.enable = true;
    # Enable interface to sensors like Accelerometers and Light sensors
    sensor.iio.enable = true;
  };

  services.udev.extraHwdb = ''
    # GPD Pocket 4
    sensor:modalias:acpi:MXC6655*:dmi:*:svnGPD:pnG1628-04:*
     ACCEL_MOUNT_MATRIX=-1, 0, 0; 0, 1, 0; 0, 0, 1
  '';

  # Enable fprintd
  services.fprintd = {
    enable = false;
    package = pkgs.fprintd.override {
      libfprint = libfprint-focaltech;
    };
  };
}
