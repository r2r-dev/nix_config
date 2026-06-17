{
  config,
  lib,
  ...
}:

{
  environment.persistence.main =
    lib.mkIf config.modules.nixos.impermanence.enable
      {
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
