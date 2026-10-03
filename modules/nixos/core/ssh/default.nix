# SSH: the OpenSSH server, persisting host keys on impermanent hosts.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.ssh;
in
{
  options.my.ssh = {
    enable = lib.mkEnableOption "the OpenSSH server";
  };

  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;
    my.persist = {
      files = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"

        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };
}
