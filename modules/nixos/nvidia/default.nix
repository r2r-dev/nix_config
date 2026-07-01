# NVIDIA: proprietary/open NVIDIA driver setup with a pinned driver version.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.nvidia;
in
{
  options.modules.nixos.nvidia = {
    enable = lib.mkEnableOption "the NVIDIA graphics driver";
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

      #package = config.boot.kernelPackages.nvidiaPackages.new_feature;
      # pin driver version https://www.nvidia.com/en-us/drivers/unix/
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "610.43.02";
        sha256_64bit = "sha256-MDSgVLtM33dS/43CclZMsQVROAS/9TU4lFkBsWyndGM=";
        sha256_aarch64 = "sha256-isWTnokUA/dzWocFBLalnk4+O5gSExVjs3dVpdYTU88=";
        openSha256 = "sha256-hP5NVZZ4vGsACHLmUDKq4uckpd/kn1GxCSYnnJfAuBs=";
        settingsSha256 = "sha256-0YAhufRgjDW+uR+kjaTb154fibpcDw8QowfrucoZsKE=";
        persistencedSha256 = "sha256-Whgv9X+v2fRhzliOl2LzltY9v1SxDafFfv3IUPqj/hk=";
      };
    };
  };
}
