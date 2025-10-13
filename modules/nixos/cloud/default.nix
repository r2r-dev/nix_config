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
    "83048a0632f6a8b8" # r2r cloud
  ];
  services.dnsmasq = {
    enable = true;
    settings.server = [
      "/szamszur.cloud/192.168.10.5"
      "/puqu.io/192.168.25.5"
      "/warp.r2r.sh/192.168.1.8"
    ];
  };
}
