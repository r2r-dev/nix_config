# Locale: system time zone plus an optional en_GB/pl_PL regional bundle.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.locale;
in
{
  options.modules.nixos.locale = {
    enable = lib.mkEnableOption "time zone and locale settings";
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Warsaw";
      description = "System time zone.";
    };
    regional = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Use the en_GB default locale with Polish (pl_PL) regional formats
        for addresses, measurement, monetary values, etc.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = cfg.timeZone;

    i18n = lib.mkIf cfg.regional {
      defaultLocale = "en_GB.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "pl_PL.UTF-8";
        LC_IDENTIFICATION = "pl_PL.UTF-8";
        LC_MEASUREMENT = "pl_PL.UTF-8";
        LC_MONETARY = "pl_PL.UTF-8";
        LC_NAME = "pl_PL.UTF-8";
        LC_NUMERIC = "pl_PL.UTF-8";
        LC_PAPER = "pl_PL.UTF-8";
        LC_TELEPHONE = "pl_PL.UTF-8";
        LC_TIME = "pl_PL.UTF-8";
      };
    };
  };
}
