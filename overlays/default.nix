# Overlay applied to every host's nixpkgs.
final: prev:
import ../pkgs final
// {
  linux-firmware = prev.linux-firmware.overrideAttrs rec {
    version = "20250613";
    src = final.fetchzip {
      url = "https://gitlab.com/kernel-firmware/linux-firmware/-/archive/${version}/linux-firmware-${version}.zip";
      hash = "sha256-qygwQNl99oeHiCksaPqxxeH+H7hqRjbqN++Hf9X+gzs=";
    };
  };
}
