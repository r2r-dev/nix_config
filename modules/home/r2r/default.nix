# Shared home-manager configuration for the r2r user.
# Host-specific packages and persistence are layered on top in each
# machine's configuration.
{ pkgs, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  home.packages = with pkgs; [
    keepassxc
    python3
    sshfs # TODO ssh module
  ];
  programs = {
    bash.enable = true;
    firefox = {
      enable = true;
      # Keep the legacy profile location (~/.mozilla/firefox) rather than the
      # new XDG default, to avoid relocating the existing on-disk profile.
      configPath = ".mozilla/firefox";
    };
    vim.enable = true;
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.11";
}
