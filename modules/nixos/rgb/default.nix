# RGB: OpenRGB hardware lighting control (with i2c access for the primary user).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.rgb;
in
{
  options.my.rgb = {
    enable = lib.mkEnableOption "OpenRGB hardware lighting control";
  };

  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      motherboard = "amd";
      enable = true;
      package = pkgs.openrgb_git.overrideAttrs (
        _: _: {
          installPhase = ''
            export LC_ALL=C.UTF-8
            mkdir $out
            mkdir -p $out/etc/systemd
            make install
          '';
        }
      );
    };
    networking.firewall.allowedTCPPorts = [ 6742 ];
    hardware.i2c.enable = true;
    environment.systemPackages = with pkgs; [
      i2c-tools # openrgb
    ];
    boot.kernelModules = [
      "i2c-piix4" # secondary i2c sensor - for rgb?
    ];
    users.groups.i2c.members = [ config.my.user.name ]; # openrgb: i2c access for the primary user
  };
}
