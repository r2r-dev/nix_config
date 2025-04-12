{
  pkgs,
  ...
}:

{
  services.hardware.openrgb = {
    motherboard = "amd";
    enable = true;
    package = pkgs.openrgb-with-all-plugins.overrideAttrs (_: rec {
      version = "0.9.1";
      postPatch =
        let
          inherit (pkgs) coreutils;
        in
        ''
          patchShebangs scripts/build-udev-rules.sh
          substituteInPlace scripts/build-udev-rules.sh \
            --replace /bin/chmod "${coreutils}/bin/chmod" \
            --replace /usr/bin/env  "${coreutils}/bin/env"
        '';
      patches = [
        ./33f43f4d37a1c3af8c123829e01dedb4b9a32718.patch # x870e aorus
      ];
      src = pkgs.fetchFromGitLab {
        owner = "CalcProgrammer1";
        repo = "OpenRGB";
        rev = "1bfd0fbd1f7a0e4ab8171bb8c7220f91c1f36c0a";
        sha256 = "sha256-l4SahOzkkZdzIssgW1/vpbnWf4ZZg5iu5tr9Z2pF30A=";
      };
    });
  };
  hardware.i2c.enable = true;
  environment.systemPackages = with pkgs; [
    i2c-tools # openrgb
  ];
  boot.kernelModules = [
    "i2c-piix4" # secondary i2c sensor - for rgb?
  ];
  users.groups.i2c.members = [ "r2r" ]; # openrgb: create i2c group and add default user to it

}
