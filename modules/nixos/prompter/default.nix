{
  config,
  pkgs,
  ...
}:

{
  services.xserver.videoDrivers = [
    "displaylink" # elgato prompter display
  ];
  boot = {
    kernelPackages =
      let
        kpkgs = pkgs.linuxPackagesFor config.kernel.package; # outoftree.pkgs.${pkgs.system}.linux_zen;
      in
      kpkgs.extend (
        _: __: {
          evdi = kpkgs.evdi.overrideDerivation (_: rec {
            version = "1.14.9";
            src = pkgs.fetchFromGitHub {
              owner = "DisplayLink";
              repo = "evdi";
              tag = "v${version}";
              hash = "sha256-tkDsVa2A8DQkMAYerx7CEtPUQYG7RomNc/UsN9tZpqo=";
            };
          });
        }
      );
  };
}
