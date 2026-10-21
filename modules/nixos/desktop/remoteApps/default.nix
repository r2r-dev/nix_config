# run graphical programs on another host and show them here
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktop.remoteApps;

  remote-app = pkgs.writeShellApplication {
    name = "remote-app";
    runtimeInputs = [ pkgs.waypipe ];
    text = ''
      if [ $# -lt 2 ]; then
        echo "usage: remote-app <ssh-host> <command> [args...]" >&2
        exit 1
      fi
      host=$1
      shift
      # shellcheck disable=SC2086
      exec waypipe ''${WAYPIPE_OPTS:---no-gpu --compress lz4} \
        --xwls ssh "$host" "$@"
    '';
  };

  # hijack hosts steam
  remote-steam = pkgs.writeShellApplication {
    name = "remote-steam";
    runtimeInputs = [
      remote-app
      pkgs.openssh
    ];
    text = ''
      if [ $# -ne 1 ]; then
        echo "usage: remote-steam <ssh-host>" >&2
        exit 1
      fi
      host=$1
      ssh "$host" steam-session stop
      trap 'ssh "$host" steam-session start' EXIT
      remote-app "$host" steam
    '';
  };
in
{
  options.my.desktop.remoteApps = {
    enable = lib.mkEnableOption "run graphical programs across hosts with waypipe";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.xwayland-satellite
      pkgs.waypipe
      remote-app
      remote-steam
    ];
  };
}
