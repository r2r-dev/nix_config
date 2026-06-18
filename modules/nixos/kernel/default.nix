# Kernel: selects the kernel package (defaults to the Zen kernel).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixos.kernel;
in
{
  options.modules.nixos.kernel = {
    enable = lib.mkEnableOption "managing the kernel package via this module";
    kernelPackages = lib.mkOption {
      default = pkgs.linuxPackages_zen;
      type = lib.types.raw;
      description = "Kernel package set to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      inherit (cfg) kernelPackages;
    };
  };
}
