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
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf (cfg.enable) {
    environment.persistence."/persist" =
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
      hostName = "samsara"; # Define your hostname. # TODO: configurable
      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      useDHCP = lib.mkDefault true;
      networkmanager.enable = true; # Easiest to use and most distros use this by default.
    };
    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = true;
    };
  };
}
