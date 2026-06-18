# Secrets: agenix-managed secrets for the r2r user (currently the login
# password), keyed off the host's SSH host keys.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.secrets;
in
{
  options.modules.nixos.secrets = {
    enable = lib.mkEnableOption "agenix secrets for the r2r user";
    sshHostKeyDir = lib.mkOption {
      type = lib.types.str;
      default = "/etc/ssh";
      description = ''
        Directory holding the SSH host keys agenix uses as identities.
        On impermanent hosts this lives under /persist.
      '';
      example = "/persist/etc/ssh";
    };
  };

  config = lib.mkIf cfg.enable {
    age = {
      identityPaths = [
        "${cfg.sshHostKeyDir}/ssh_host_ed25519_key"
        "${cfg.sshHostKeyDir}/ssh_host_rsa_key"
      ];
      secrets = {
        "r2r.passwd".file = ../../../secrets/r2r.passwd.age;
      };
    };
  };
}
