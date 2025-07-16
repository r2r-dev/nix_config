{
  config,
  lib,
  ...
}:
{
  environment.persistence."/persist" = lib.mkIf config.r2r.impermanence.enable {
    files = [
      "/var/lib/zerotier-one/networks.d/363c67c55a95648e.conf" # szamszur cloud
    ];
  };
  services.zerotierone.joinNetworks = [
    "363c67c55a95648e" # szamszur cloud
  ];
  services.dnsmasq = {
    enable = true;
    #resolveLocalQueries = true;
    settings.server = [
      "/szamszur.cloud/192.168.10.5"
      "/puqu.io/192.168.25.5"
    ];
  };
}
