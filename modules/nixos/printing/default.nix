# Printing: CUPS printing with Avahi mDNS for network printer discovery.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixos.printing;
in
{
  options.modules.nixos.printing = {
    enable = lib.mkEnableOption "CUPS printing (with Avahi mDNS discovery)";
  };

  config = lib.mkIf cfg.enable {
    # mDNS, used for network printer discovery (and general .local resolution).
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        cups-filters
        cups-browsed
      ];
    };
  };
}
