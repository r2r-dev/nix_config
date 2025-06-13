{
  config,
  lib,
  pkgs,
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
  hardware.nvidia = 
  let
      #https://github.com/NixOS/nixpkgs/issues/411829#issuecomment-2962741405
      gpl_symbols_linux_615_patch = pkgs.fetchpatch {
        url = "https://github.com/CachyOS/kernel-patches/raw/914aea4298e3744beddad09f3d2773d71839b182/6.15/misc/nvidia/0003-Workaround-nv_vm_flags_-calling-GPL-only-code.patch";
        hash = "sha256-YOTAvONchPPSVDP9eJ9236pAPtxYK5nAePNtm2dlvb4=";
        stripLen = 1;
        extraPrefix = "kernel/";
      };
  in {
    # This will no longer be necessary when
    # https://github.com/NixOS/nixpkgs/pull/326369 hits stable
    modesetting.enable = lib.mkDefault true;
    # Power management is nearly always required to get nvidia GPUs to
    # behave on suspend, due to firmware bugs.
    powerManagement.enable = true;
    # The open driver is recommended by nvidia now, see
    # https://download.nvidia.com/XFree86/Linux-x86_64/565.57.01/README/kernel_open.html
    open = false; # not with 6.15 patch

    # pin driver version https://www.nvidia.com/en-us/drivers/unix/
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "575.57.08";
      sha256_64bit = "sha256-KqcB2sGAp7IKbleMzNkB3tjUTlfWBYDwj50o3R//xvI=";
      sha256_aarch64 = "sha256-VJ5z5PdAL2YnXuZltuOirl179XKWt0O4JNcT8gUgO98=";
      openSha256 = "sha256-DOJw73sjhQoy+5R0GHGnUddE6xaXb/z/Ihq3BKBf+lg=";
      settingsSha256 = "sha256-AIeeDXFEo9VEKCgXnY3QvrW5iWZeIVg4LBCeRtMs5Io=";
      persistencedSha256 = "sha256-Len7Va4HYp5r3wMpAhL4VsPu5S0JOshPFywbO7vYnGo=";

      patches = [ gpl_symbols_linux_615_patch ];
    };
  };
}
