{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.kernel;
in
{
  options.kernel = {

    package = mkOption {
      type = types.package;
      default = pkgs.linuxPackages_cachyos.kernel;
      description = "kernel package to use.";
    };

    config = {
      boot = {
        kernelPackages = cfg.package;
      };
    };
  };
}
