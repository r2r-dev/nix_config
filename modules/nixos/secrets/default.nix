# Secrets: agenix decryption using the host's SSH host keys as identities.
# The keys are read from the persistent volume on impermanent hosts, since
# agenix runs before the persisted files are bind-mounted into /etc.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.secrets;
  persist = config.my.persist;
  sshHostKeyDir =
    if persist.enable then "${persist.root}/etc/ssh" else "/etc/ssh";
in
{
  options.my.secrets = {
    enable = lib.mkEnableOption "agenix secrets keyed off the SSH host keys";
  };

  config = lib.mkIf cfg.enable {
    age.identityPaths = [
      "${sshHostKeyDir}/ssh_host_ed25519_key"
      "${sshHostKeyDir}/ssh_host_rsa_key"
    ];
    age.secrets."r2r.passwd".file = ../../../secrets/r2r.passwd.age;
  };
}
