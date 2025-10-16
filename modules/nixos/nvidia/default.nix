{
  config,
  lib,
  ...
}:

{

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

    package = config.boot.kernelPackages.nvidiaPackages.latest;
    # pin driver version https://www.nvidia.com/en-us/drivers/unix/
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
    #package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #  version = "580.65.06";
    #  sha256_64bit = "sha256-BLEIZ69YXnZc+/3POe1fS9ESN1vrqwFy6qGHxqpQJP8=";
    #  sha256_aarch64 = "sha256-4CrNwNINSlQapQJr/dsbm0/GvGSuOwT/nLnIknAM+cQ=";
    #  openSha256 = "sha256-BKe6LQ1ZSrHUOSoV6UCksUE0+TIa0WcCHZv4lagfIgA=";
    #  settingsSha256 = "sha256-9PWmj9qG/Ms8Ol5vLQD3Dlhuw4iaFtVHNC0hSyMCU24=";
    #  persistencedSha256 = "sha256-ETRfj2/kPbKYX1NzE0dGr/ulMuzbICIpceXdCRDkAxA=";
    #};
  };
}
