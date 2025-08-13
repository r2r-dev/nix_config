{
  pkgs,
  ...
}:

{
  services.hardware.openrgb = {
    motherboard = "amd";
    enable = true;
    package = pkgs.openrgb_git.overrideAttrs (
      finalAttrs: previousAttrs: {
        installPhase = ''
          export LC_ALL=C.UTF-8
          mkdir $out
          mkdir -p $out/etc/systemd
          make install
        '';
        postPatch = ''
          substituteInPlace OpenRGB.pro \
          --replace-fail "/etc/systemd" "$out/etc/systemd"
        ''
        + previousAttrs.postPatch;
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
  users.groups.i2c.members = [ "r2r" ]; # openrgb: create i2c group and add default user to it

}
