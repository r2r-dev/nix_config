# Cursor: one cursor theme for the primary user's session (GTK, X11/XWayland
# and Hyprland via home-manager) and the greeter.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktop.cursor;
in
{
  options.my.desktop.cursor = {
    enable = lib.mkEnableOption "a fixed cursor theme";
    package = lib.mkPackageOption pkgs "graphite-cursors" { };
    name = lib.mkOption {
      type = lib.types.str;
      default = "graphite-light";
      description = "Cursor theme name inside the package.";
    };
    size = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Cursor size in pixels.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${config.my.user.name}.home.pointerCursor = {
      enable = true;
      inherit (cfg) package name size;
      gtk.enable = true; # GTK apps
      x11.enable = true; # XWayland apps
      hyprcursor.enable = config.programs.hyprland.enable; # Hyprland
    };

    services.displayManager.noctalia-greeter.settings =
      lib.mkIf config.services.displayManager.noctalia-greeter.enable
        {
          cursor.size = cfg.size;
          path = "${cfg.package}/share/icons";
        };
  };
}
