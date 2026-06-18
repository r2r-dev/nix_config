# Network: NetworkManager networking with a configurable hostname, optional
# dnsmasq resolver, and persisted connections on impermanent hosts.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.network;
in
{
  options.modules.nixos.network = {
    enable = lib.mkEnableOption "NetworkManager-based networking";
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "System hostname.";
      example = "samsara";
    };
    dnsmasq = lib.mkEnableOption "the dnsmasq local resolver";
  };
  config = lib.mkIf cfg.enable {
    environment.persistence.main =
      lib.mkIf config.modules.nixos.impermanence.enable
        {
          directories = [
            "/etc/NetworkManager/system-connections"
          ];
          files = [
            "/var/lib/NetworkManager/secret_key" # Network Manager
            "/var/lib/NetworkManager/seen-bssids" # Network Manager
            "/var/lib/NetworkManager/timestamps" # Network Manager
          ];
        };
    networking = {
      hostName = cfg.hostName;
      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      useDHCP = lib.mkDefault true;
      networkmanager.enable = true; # Easiest to use and most distros use this by default.
    };
    services.dnsmasq = lib.mkIf cfg.dnsmasq {
      enable = true;
      resolveLocalQueries = true;
    };
  };
}
