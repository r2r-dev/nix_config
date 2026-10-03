# Keyboard: one place for the keyboard layout (X11/Wayland xkb, console and
# anything that reads them, e.g. the greeter), plus optional keyd remapping.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.keyboard;
in
{
  options.my.keyboard = {
    layout = lib.mkOption {
      type = lib.types.str;
      default = "pl";
      description = "XKB keyboard layout.";
    };
    consoleKeyMap = lib.mkOption {
      type = lib.types.str;
      default = "pl2";
      description = "Keymap of the virtual console.";
    };
    remap = {
      enable = lib.mkEnableOption "keyd key remapping on all keyboards";
      main = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "keyd bindings for the main layer.";
        example = {
          capslock = "overload(control, esc)";
          esc = "capslock";
          shift = "oneshot(shift)";
          leftalt = "oneshot(altgr)";
          rightalt = "oneshot(altgr)";
        };
      };
    };
  };

  config = lib.mkMerge [
    {
      services.xserver.xkb.layout = cfg.layout;
      console.keyMap = cfg.consoleKeyMap;
    }
    (lib.mkIf cfg.remap.enable {
      services.keyd = {
        enable = true;
        keyboards.default = {
          ids = [ "*" ];
          settings.main = cfg.remap.main;
        };
      };
    })
  ];
}
