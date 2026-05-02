{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fnltochkaLib.themes;
  gdmEnabled = config.services.displayManager.gdm.enable or false;
in {
  options.fnltochkaLib.themes.cursor = {
    enable = lib.mkEnableOption "system cursor theme (XCURSOR + optional GDM login screen)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bibata-cursors;
      description = "Cursor theme package (must provide share/icons/<cursor-name>).";
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = "Bibata-Modern-Classic";
      description = "Cursor theme name (directory name under share/icons).";
    };

    size = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Cursor size.";
    };

    applyToGdm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Also apply cursor theme to the GDM login screen (when GDM is enabled).";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (config.fnltochkaLib.desktop.enable or false) {
      fnltochkaLib.themes.cursor.enable = lib.mkDefault true;
    })

    (lib.mkIf cfg.cursor.enable {
      environment.systemPackages = [cfg.cursor.package];

      environment.variables = {
        XCURSOR_THEME = cfg.cursor.name;
        XCURSOR_SIZE = toString cfg.cursor.size;
      };
    })

    (lib.mkIf (cfg.cursor.enable && cfg.cursor.applyToGdm && gdmEnabled) {
      programs.dconf.enable = lib.mkDefault true;

      programs.dconf.profiles.gdm.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              cursor-theme = cfg.cursor.name;
              cursor-size = lib.gvariant.mkInt32 cfg.cursor.size;
            };
          };
        }
      ];
    })
  ];
}
