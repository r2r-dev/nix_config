{ system, outoftree }:
self: super: {
  linux-firmware = super.linux-firmware.overrideAttrs rec {
    version = "20250613";
    src = self.fetchzip {
      url = "https://gitlab.com/kernel-firmware/linux-firmware/-/archive/${version}/linux-firmware-${version}.zip";
      hash = "sha256-qygwQNl99oeHiCksaPqxxeH+H7hqRjbqN++Hf9X+gzs=";
    };
  };
}
