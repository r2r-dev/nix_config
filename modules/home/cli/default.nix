# CLI: terminal tools.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.cli.enable = lib.mkEnableOption "the terminal tools";

  config = lib.mkIf config.my.cli.enable {
    programs.vim.enable = true;
    my.persist.directories = [
      ".gnupg"
      ".ssh"
    ];
    home.packages = with pkgs; [
      nixfmt
      python3
      sshfs # TODO ssh module
    ];
  };
}
