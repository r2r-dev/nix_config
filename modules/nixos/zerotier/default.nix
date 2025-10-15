{
  config,
  lib,
  ...
}:
{
  services.zerotierone.enable = true;
  environment.persistence."/persist" =
    lib.mkIf config.r2r.impermanence.enable
      {
        files = [
          "/var/lib/zerotier-one/identity.secret"
          "/var/lib/zerotier-one/identity.public"
        ];
      };
}
