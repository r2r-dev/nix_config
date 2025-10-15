{
  config,
  lib,
  ...
}:
let
  cfg = config.cloud;
in
{
  options.cloud = {
    enable = lib.mkEnableOption "cloud";
    warp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    puqu.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf cfg.enable {
      environment.persistence."/persist" =
        lib.mkIf config.r2r.impermanence.enable
          {
            files = [
              (lib.mkIf cfg.puqu.enable "/var/lib/zerotier-one/networks.d/363c67c55a95648e.conf") # szamszur cloud
              (lib.mkIf cfg.warp.enable "/var/lib/zerotier-one/networks.d/83048a0632f6a8b8.conf") # r2r cloud
            ];
          };
      services.zerotierone.joinNetworks = [
        (lib.mkIf cfg.puqu.enable "363c67c55a95648e") # szamszur cloud
        (lib.mkIf cfg.warp.enable "83048a0632f6a8b8") # r2r cloud
      ];
      services.dnsmasq = {
        enable = true;
        settings.server = [
          (lib.mkIf cfg.puqu.enable "/szamszur.cloud/192.168.10.5")
          (lib.mkIf cfg.puqu.enable "/puqu.io/192.168.25.5")
          #lib.mkIf cfg.warp.enable "/warp.r2r.sh/192.168.1.8"
        ];
      };
    };
}
