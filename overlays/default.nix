{ system, outoftree }:
self: super: {
  linux_zen_git = outoftree.pkgs.${system}.linux_zen;
}
