# Network: NetworkManager networking with an optional
# dnsmasq resolver, and persisted connections on impermanent hosts.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.network;
in
{
  options.my.network = {
    enable = lib.mkEnableOption "NetworkManager-based networking";
    dnsmasq = lib.mkEnableOption "the dnsmasq local resolver";
  };
  config = lib.mkIf cfg.enable {
    environment.persistence.main = lib.mkIf config.my.impermanence.enable {
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
