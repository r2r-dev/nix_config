{
  config,
  lib,
  pkgs,
  outoftree,
  ...
}:

with lib;

let
  cfg = config.kernel;
in
{
  options.kernel = {
    #enable = mkEnableOption "kernel package management";

    package = mkOption {
      type = types.package;
      default = outoftree.pkgs.${pkgs.system}.linux_zen;
      defaultText = literalExpression "pkgs.linuxPackages_zen";
      description = "kernel package to use.";
    };

    config = {
      boot = {
        kernelPackages = cfg.package;
        # Zen Kernel is a fork of Linux that applies out-of-tree features, early backports, and fixes, that impact desktop usage of Linux. Many of the features that change system behavior are hidden behind CONFIG_ZEN_INTERACTIVE, while many others are always available or configurable (such as CONFIG_MUQSS), for custom builds and distributions of Zen Kernel.
        #kernelPackages = pkgs.linuxPackages_zen; # https://github.com/zen-kernel/zen-kernel/wiki/Detailed-Feature-List
        #kernelPackages = pkgs.linuxPackages_latest;
      };
    };
  };
}
