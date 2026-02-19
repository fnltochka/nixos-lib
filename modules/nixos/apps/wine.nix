{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fnltochkaLib.apps.wine;
in {
  options.fnltochkaLib.apps.wine = {
    enable = lib.mkEnableOption "Wine (Windows compatibility layer)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.wineWowPackages.staging;
      defaultText = "pkgs.wineWowPackages.staging";
      description = "Which Wine package to install.";
    };

    fonts = {
      enable = lib.mkEnableOption "Wine replacement fonts (wine-fonts)";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.wineWowPackages.fonts;
        defaultText = "pkgs.wineWowPackages.fonts";
        description = "Which wine-fonts package to install.";
      };
    };

    asio.enable = lib.mkEnableOption "wineasio (ASIO to JACK driver for Wine)";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable32Bit = lib.mkDefault true;
    services.pipewire.alsa.support32Bit = lib.mkDefault true;

    fnltochkaLib.apps.wine.fonts.enable = lib.mkDefault true;

    services.pipewire.jack.enable = lib.mkIf cfg.asio.enable (lib.mkDefault true);

    environment.systemPackages =
      [
        cfg.package
        pkgs.winetricks
      ]
      ++ lib.optionals cfg.fonts.enable [
        cfg.fonts.package
      ]
      ++ lib.optionals
      cfg.asio.enable [
        pkgs.wineasio
      ];
  };
}
