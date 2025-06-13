{ system, outoftree }:
self: super: {
  linux_zen_git = outoftree.pkgs.${system}.linux_zen;

  # in the the latest linux-firmware the ath12k firmware is broken. by reverting the patch that introduced it, we flip to the last known good version.
  # as described in https://bbs.archlinux.org/viewtopic.php?pid=2243026#p2243026

  # https://gitlab.com/kernel-firmware/linux-firmware/-/commit/2e91d8c3c4bd34a27177180a38f62d3ba3c96031
  # https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/commit/?id=2e91d8c3c4bd34a27177180a38f62d3ba3c96031
  # kernel support for the new firmware is expected to land in 6.16.
  # or in 6.15 with these patches
  # https://lists.infradead.org/pipermail/ath12k/2025-May/007078.html
  # https://0x0.st/s/yfQHTDVDbzo7M5b6dHswjg/83Xm.15
  linux-firmware = super.linux-firmware.overrideAttrs rec {
    version = "20250613";
    src = self.fetchzip {
      url = "https://gitlab.com/kernel-firmware/linux-firmware/-/archive/${version}/linux-firmware-${version}.zip";
      hash = "sha256-qygwQNl99oeHiCksaPqxxeH+H7hqRjbqN++Hf9X+gzs=";
    };
  };
}
