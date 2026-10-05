# NVIDIA: proprietary/open NVIDIA driver setup with a pinned driver version.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.hardware.nvidia;
in
{
  options.my.hardware.nvidia = {
    enable = lib.mkEnableOption "the NVIDIA graphics driver" // {
      default = config.my.hardware.gpu == "nvidia";
      defaultText = lib.literalExpression ''config.my.hardware.gpu == "nvidia"'';
    };
  };

  config = lib.mkIf cfg.enable {
    # https://github.com/TLATER/dotfiles/blob/96c43068c47b1234d776b0d7366818eb04533c67/nixos-modules/nvidia/default.nix#L103
    boot.extraModprobeConfig =
      let
        options = [
          "NVreg_UsePageAttributeTable=1"
          "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
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

      # Pinned driver (https://www.nvidia.com/en-us/drivers/unix/,
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix).
      #
      # 610.57.04 rather than 615.71.09 (nixpkgs' new_feature): 615.71.09
      # regressed on DisplayPort - pixel corruption/vertical lines and GSP
      # hangs on modeset/hotplug, fixed by going back to 610.57.04:
      # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1367
      # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1392
      # (610.43.02 does not build on kernel 7.2:
      # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1224)
      # Fallback if this fails to build on a newer kernel:
      #   config.boot.kernelPackages.nvidiaPackages.production
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "610.57.04";
        sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
        sha256_aarch64 = "sha256-QCefrMBCmpOwuOyXv1k5Gj0iB2CYlPgnG3JToUw/j54=";
        openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
        settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
        persistencedSha256 = "sha256-aXmD2VY1RLlgAnlHhOUMWzvMyhI6JTClcFLm4imF/mA=";
      };
    };
  };
}
