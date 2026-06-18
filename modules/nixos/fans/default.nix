# Fans: CoolerControl userspace fan control, optionally with the it87
# temperature sensor kernel module for desktop boards.
{
  config,
  lib,
  pkgs,
  outoftree,
  ...
}:
let
  cfg = config.modules.nixos.fans;
in
{
  options.modules.nixos.fans = {
    enable = lib.mkEnableOption "CoolerControl-based fan control";
    it87.enable = lib.mkEnableOption "the it87 temperature sensor kernel module (desktop boards)";
  };
  config = lib.mkIf cfg.enable {
    boot = lib.mkIf cfg.it87.enable {
      kernelParams = [
        "acpi_enforce_resources=lax" # proper temp - fan loop
      ];
      kernelModules = [
        "k10temp" # temperature sensor
        "it87" # temperature sensor
      ];
      extraModulePackages = with config.boot.kernelPackages; [
        (lib.hiPrio (
          outoftree.pkgs.${pkgs.system}.it87.overrideAttrs (super: {
            # Updates to newer version, needed by X870E aorus master mobo https://github.com/NixOS/nixpkgs/pull/399927
            postInstall = (super.postInstall or "") + ''
              find $out -name '*.ko' -exec xz {} \;
            '';
          })
        )) # it87
      ];
      extraModprobeConfig = ''
        options it87 ignore_resource_conflict=1 mmio=1
      ''; # make temp sensor behave
    };

    environment.systemPackages = with pkgs; [
      # fans
      coolercontrol.coolercontrold
      #coolercontrol.coolercontrol-liqctld
      liquidctl
      lm_sensors # tools and drivers for monitoring temperatures, voltage, and fans
    ];

    programs.coolercontrol.enable = true;
  };
}
