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
    package = lib.mkOption {
      type = lib.types.package;
      default = config.boot.kernelPackages.nvidiaPackages.latest;
      defaultText = lib.literalExpression "config.boot.kernelPackages.nvidiaPackages.latest";
      description = ''
        Driver package. Defaults to the newest driver nixpkgs ships for the
        host's kernel (the higher of the production and new-feature
        branches), so it moves forward with flake.lock.

        Known issue (Oct 2026): 610.57.04 and newer corrupt the screen in
        gamescope's DRM backend at 4K (gamescope#2309); 615.71.09 also
        regressed on some DisplayPort setups
        (open-gpu-kernel-modules#1367, #1392). If that bites, use
        `config.boot.kernelPackages.nvidiaPackages.production` here.
      '';
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

      inherit (cfg) package;
    };
  };
}
