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
      exec waypipe ''${WAYPIPE_OPTS:---video h264,hw --compress lz4} \
        --xwls ssh "$host" "$@"
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
      remote-app
    ];
  };
}
