# Locale and timezone defaults (fnltochkaLib.system.locale)
#
# Sets time.timeZone and i18n.defaultLocale / i18n.extraLocaleSettings
# when enabled.
{
  config,
  lib,
  ...
}: let
  cfg = config.fnltochkaLib.system.locale;
in {
  options.fnltochkaLib.system.locale = {
    enable = lib.mkEnableOption "locale and timezone defaults";

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Moscow";
      description = "Time zone (e.g. Europe/Moscow)";
    };

    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "Default locale";
    };
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = cfg.timeZone;
    i18n.defaultLocale = cfg.defaultLocale;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
  };
}
