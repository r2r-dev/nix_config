# Hardware facts about the host that other modules adapt to.
{ lib, ... }:
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
        (`nvidia` enables my.nvidia) and GPU-specific tweaks in other
        modules (wolf, performance).
      '';
    };
  };
}
