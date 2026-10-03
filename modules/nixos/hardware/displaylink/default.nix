# DisplayLink: USB display adapters, using nixpkgs' DisplayLink support
# (evdi kernel module, udev rules and the DisplayLinkManager `dlm` service,
# started when an adapter is plugged in, with suspend/resume hooks).
#
# The displaylink package needs its driver archive added to the store by
# hand once (see `nix-build '<nixpkgs>' -A displaylink` for instructions).
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.hardware.displaylink;
in
{
  options.my.hardware.displaylink = {
    enable = lib.mkEnableOption "DisplayLink USB display support";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [
      "displaylink"
      "modesetting"
    ];

    # KWin defaults to 30-bit colour, which evdi outputs can't do.
    environment.variables = lib.mkIf config.services.desktopManager.plasma6.enable {
      KWIN_DRM_PREFER_COLOR_DEPTH = "24";
    };
  };
}
