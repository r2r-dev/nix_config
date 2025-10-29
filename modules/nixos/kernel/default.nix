{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.nixos.kernel;
in
{
  options.modules.nixos.kernel = {
    kernelPackages = mkOption {
      default = pkgs.linuxPackages_zen;
      type = types.raw;
      description = "kernel package to use.";
    };
  };
  config = {
    boot = {
      inherit (cfg) kernelPackages;
    };
  };
}
