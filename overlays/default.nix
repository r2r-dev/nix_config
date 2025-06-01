{ system, outoftree }:
self: super: {
  linux_zen_git = outoftree.pkgs.${system}.linux_zen;

  # Upgrade linux-firmware, the ath12k firmware is broken on the latest official version.
  linux-firmware = super.linux-firmware.overrideAttrs rec {
    version = "f4e75db20a11ed07b86017f76c7b428e1fa3f40d";
    src = self.fetchzip {
      url = "https://gitlab.com/kernel-firmware/linux-firmware/-/archive/f4e75db20a11ed07b86017f76c7b428e1fa3f40d/linux-firmware-f4e75db20a11ed07b86017f76c7b428e1fa3f40d.zip";
      hash = "sha256-WmCw9xRUP8HT3yY5EEJVSbUEVAKCJ2wk3KNoApsPzMU=";
    };
  };
}
