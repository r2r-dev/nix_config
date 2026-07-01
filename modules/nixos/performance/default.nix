{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.performance;
in
{
  options.modules.nixos.performance = {
    enable = lib.mkEnableOption "gaming performance tweaks (sched-ext, Proton env, zram)";
    scheduler = lib.mkOption {
      type = lib.types.str;
      default = "scx_lavd";
      description = ''
        sched-ext scheduler to run. scx_lavd is latency-optimised for
        gaming
      '';
    };
    disableMitigations = lib.mkEnableOption "disabling CPU security mitigations";
  };

  config = lib.mkIf cfg.enable {
    #scheduler for smoother frametimes
    services.scx = {
      enable = true;
      scheduler = cfg.scheduler;
    };

    boot.kernelParams = lib.optional cfg.disableMitigations "mitigations=off";
    #faster-than-fsync Proton synchronisation
    boot.kernelModules = [ "ntsync" ];

    # compress swap in RAM
    zramSwap.enable = true;

    environment.sessionVariables = {
      PROTON_ENABLE_NVAPI = "1"; # DLSS
      PROTON_USE_NTSYNC = "1"; # use the ntsync
      __GL_THREADED_OPTIMIZATIONS = "1";
    };
  };
}
