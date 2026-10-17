{
  config,
  lib,
  ...
}:
let
  cfg = config.my.gaming.performance;
in
{
  options.my.gaming.performance = {
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
    splitLockDetect = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Keep the kernel's split-lock detection. By default it is turned off:
        in its default "warn" mode the kernel deliberately stalls any thread
        that does a misaligned locked operation, which Steam/CEF and some
        Windows games do constantly ("x86/split lock detection: #DB ... took a
        bus_lock trap" in the journal), causing stutter.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    #scheduler for smoother frametimes
    services.scx = {
      enable = true;
      scheduler = cfg.scheduler;
    };

    boot.kernelParams =
      lib.optional cfg.disableMitigations "mitigations=off"
      ++ lib.optional (!cfg.splitLockDetect) "split_lock_detect=off";
    #faster-than-fsync Proton synchronisation
    boot.kernelModules = [ "ntsync" ];

    # compress swap in RAM
    zramSwap.enable = true;

    environment.sessionVariables = {
      PROTON_USE_NTSYNC = "1"; # use the ntsync
    }
    // lib.optionalAttrs (config.my.hardware.gpu == "nvidia") {
      PROTON_ENABLE_NVAPI = "1"; # DLSS
      __GL_THREADED_OPTIMIZATIONS = "1";
    };
  };
}
