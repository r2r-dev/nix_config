# GPU: which GPU the host renders with. Turns on the graphics stack (with
# 32-bit support for Steam/Wine) and lets other modules adapt to the vendor.
{ config, lib, ... }:
{
  options.my.hardware = {
    gpu = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "amd"
          "intel"
          "nvidia"
        ]
      );
      default = null;
      description = ''
        Vendor of the GPU used for rendering. Selects the driver setup
        (`nvidia` enables my.hardware.nvidia) and GPU-specific tweaks in other
        modules (wolf, performance).
      '';
    };
  };

  config = lib.mkIf (config.my.hardware.gpu != null) {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
