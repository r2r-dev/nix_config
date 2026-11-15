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
    my.persist = {
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
      useDHCP = lib.mkDefault true;
      networkmanager.enable = true;
    };
    services.dnsmasq = lib.mkIf cfg.dnsmasq {
      enable = true;
      resolveLocalQueries = true;
    };
  };
}
