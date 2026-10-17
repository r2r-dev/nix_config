# NVIDIA: the NVIDIA driver (open kernel modules), following nixpkgs'
# newest driver unless a host picks another package.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.hardware.nvidia;

  # The open kernel modules with open-gpu-kernel-modules PR #1305, which
  # makes the RMDisableNoncontigAlloc registry key apply to the memory
  # allocator used on current GPUs (without it the key does nothing).
  withContiguousVram =
    pkg:
    pkg.overrideAttrs (old: {
      passthru = old.passthru // {
        open = old.passthru.open.overrideAttrs (o: {
          patches = (o.patches or [ ]) ++ [ ./rmdisablenoncontigalloc-pma.patch ];
        });
      };
    });

  registryDwords = [
    "RMUseSwI2c=0x01"
    "RMI2cSpeed=100"
  ]
  ++ lib.optional cfg.contiguousVram "RMDisableNoncontigAlloc=1";
in
{
  options.my.hardware.nvidia = {
    enable = lib.mkEnableOption "the NVIDIA graphics driver" // {
      default = config.my.hardware.gpu == "nvidia";
      defaultText = lib.literalExpression ''config.my.hardware.gpu == "nvidia"'';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = config.boot.kernelPackages.nvidiaPackages.latest;
      defaultText = lib.literalExpression "config.boot.kernelPackages.nvidiaPackages.latest";
      description = ''
        Driver package. Defaults to the newest driver nixpkgs ships for the
        host's kernel (the higher of the production and new-feature
        branches), so it moves forward with flake.lock. Use
        `config.boot.kernelPackages.nvidiaPackages.production` here when a
        release misbehaves.
      '';
    };

    contiguousVram = lib.mkEnableOption "contiguous video memory allocations" // {
      description = ''
        Work around corrupted output in gamescope's DRM backend at large
        modes (4K, HDR, 5120x1440...): the display engine cannot scan out
        buffers that are scattered in video memory, and gamescope's
        Vulkan-allocated scan-out surfaces can be (gamescope#1593, #2309).
        Sets the `RMDisableNoncontigAlloc=1` registry key and patches the
        open kernel modules so it takes effect (open-gpu-kernel-modules
        PR #1305)
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.contiguousVram -> config.hardware.nvidia.open;
        message = "my.hardware.nvidia.contiguousVram needs the open kernel modules.";
      }
    ];

    boot.extraModprobeConfig =
      let
        options = [
          "NVreg_UsePageAttributeTable=1"
          "NVreg_RegistryDwords=${lib.concatStringsSep ";" registryDwords}"
        ];
      in
      "options nvidia ${lib.concatStringsSep " " options}";

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [
      "nvidia"
    ];
    hardware.nvidia = {
      # This will no longer be necessary when
      # https://github.com/NixOS/nixpkgs/pull/326369 hits stable
      modesetting.enable = lib.mkDefault true;
      # Power management is nearly always required to get nvidia GPUs to
      # behave on suspend, due to firmware bugs.
      powerManagement.enable = true;
      # The open driver is recommended by nvidia now, see
      # https://download.nvidia.com/XFree86/Linux-x86_64/565.57.01/README/kernel_open.html
      open = true; # not with 6.15 patch

      # Keep the driver resident so the GPU does not re-initialise between
      # runs, trimming launch latency/stutter.
      nvidiaPersistenced = true;

      package =
        if cfg.contiguousVram then withContiguousVram cfg.package else cfg.package;
    };
  };
}
