# Prompter: DisplayLink support (evdi kernel module + DisplayLinkManager
# service) for external USB display adapters.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixos.prompter;
in
{
  options.modules.nixos.prompter = {
    enable = lib.mkEnableOption "DisplayLink USB display support";
  };

  config = lib.mkIf cfg.enable {
    environment.variables = {
      # if kde plasma
      KWIN_DRM_PREFER_COLOR_DEPTH = "24";
    };
    environment.systemPackages = with pkgs; [
      # if kde plasma
      displaylink
    ];
    # --- THIS IS THE CRUCIAL PART FOR ENABLING THE SERVICE ---
    systemd.services.displaylink-server = {
      enable = true;
      # Ensure it starts after udev has done its work
      requires = [ "systemd-udevd.service" ];
      after = [ "systemd-udevd.service" ];
      wantedBy = [ "multi-user.target" ]; # Start at boot
      # *** THIS IS THE CRITICAL 'serviceConfig' BLOCK ***
      serviceConfig = {
        Type = "simple"; # Or "forking" if it forks (simple is common for daemons)
        # The ExecStart path points to the DisplayLinkManager binary provided by the package
        ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
        # User and Group to run the service as (root is common for this type of daemon)
        User = "root";
        Group = "root";
        # Environment variables that the service itself might need
        # Environment = [ "DISPLAY=:0" ]; # Might be needed in some cases, but generally not for this
        Restart = "on-failure";
        RestartSec = 5; # Wait 5 seconds before restarting
      };
    };
    boot = {
      extraModulePackages = [ config.boot.kernelPackages.evdi ];
      initrd = {
        # List of modules that are always loaded by the initrd.
        kernelModules = [
          "evdi"
        ];
      };
    };
  };
}
