# Persist: the home-manager side of my.persist. Modules list the parts of
# $HOME they need to keep in `my.persist.directories` / `files`
# (paths relative to $HOME); they are only applied on hosts where the
# system's my.persist is enabled, under the same persistent volume.
{
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = config.my.persist;
  system = osConfig.my.persist;
  entry = lib.types.either lib.types.str lib.types.attrs;
in
{
  options.my.persist = {
    directories = lib.mkOption {
      type = lib.types.listOf entry;
      default = [ ];
      description = ''
        Directories under $HOME to keep across reboots. Same format as
        `home.persistence.<name>.directories`.
      '';
    };
    files = lib.mkOption {
      type = lib.types.listOf entry;
      default = [ ];
      description = ''
        Files under $HOME to keep across reboots. Same format as
        `home.persistence.<name>.files`.
      '';
    };
  };

  config = lib.mkIf system.enable {
    home.persistence.${system.root} = {
      inherit (cfg) directories files;
    };
  };
}
