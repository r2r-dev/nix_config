# SSH: the OpenSSH server, persisting host keys on impermanent hosts.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.ssh;
in
{
  options.modules.nixos.ssh = {
    enable = lib.mkEnableOption "the OpenSSH server";
  };

  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;
    environment.persistence.main =
      lib.mkIf config.modules.nixos.impermanence.enable
        {
          files = [
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"

            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
          ];
        };
  };
}
