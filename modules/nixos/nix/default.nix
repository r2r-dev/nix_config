{
  config,
  lib,
  ...
}:

{
  environment.persistence."/persist" = lib.mkIf (config.r2r.impermanence.enable) {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/nix"
      "/var/lib/nixos"
    ];
  };
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
