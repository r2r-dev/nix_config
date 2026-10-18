# ssh: client-side helpers
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.ssh.enable = lib.mkEnableOption "SSH client tools";

  config = lib.mkIf config.my.ssh.enable {
    home.packages = with pkgs; [
      sshfs
      sshx
    ];
    my.persist.directories = [ ".ssh" ];
  };
}
