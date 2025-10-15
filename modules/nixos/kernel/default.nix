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
      default = pkgs.linuxPackages_zen;
      description = "kernel package to use.";
    };

  };
    config = {
      boot = {
        kernelPackages = cfg.package;
      };
    };
}
