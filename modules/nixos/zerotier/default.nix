# ZeroTier: join the puqu and/or warp ZeroTier networks, with matching
# dnsmasq split-DNS entries and persisted identity on impermanent hosts.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.zerotier;
in
{
  options.modules.nixos.zerotier = {
    warp.enable = lib.mkEnableOption "the warp.r2r.sh ZeroTier network";
    puqu.enable = lib.mkEnableOption "the szamszur.cloud/puqu.io ZeroTier network";
  };

  config = lib.mkIf (cfg.warp.enable || cfg.puqu.enable) {
    environment.persistence.main =
      lib.mkIf config.modules.nixos.impermanence.enable
        {
          files = [
            "/var/lib/zerotier-one/identity.secret"
            "/var/lib/zerotier-one/identity.public"
            (lib.mkIf cfg.puqu.enable "/var/lib/zerotier-one/networks.d/363c67c55a95648e.conf") # szamszur cloud
            (lib.mkIf cfg.warp.enable "/var/lib/zerotier-one/networks.d/83048a0632f6a8b8.conf") # r2r cloud
          ];
        };
    services = {
      zerotierone = {
        enable = true;
        joinNetworks = [
          (lib.mkIf cfg.puqu.enable "363c67c55a95648e") # szamszur cloud
          (lib.mkIf cfg.warp.enable "83048a0632f6a8b8") # r2r cloud
        ];
      };
      dnsmasq = {
        enable = cfg.puqu.enable || cfg.warp.enable;
        settings.server = [
          (lib.mkIf cfg.puqu.enable "/szamszur.cloud/192.168.10.5")
          (lib.mkIf cfg.puqu.enable "/puqu.io/192.168.25.5")
          (lib.mkIf cfg.warp.enable "/warp.r2r.sh/192.168.168.8")
        ];
      };
    };
  };
}
