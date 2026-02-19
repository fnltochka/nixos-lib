{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  osLocale = lib.attrByPath ["i18n" "defaultLocale"] "en_US.UTF-8" osConfig;
  osDesktopEnabled = lib.attrByPath ["fnltochkaLib" "desktop" "enable"] false osConfig;
  osGnomeEnabled = lib.attrByPath ["fnltochkaLib" "desktop" "gnome" "enable"] false osConfig;
  osZshEnabled = lib.attrByPath ["fnltochkaLib" "system" "zsh" "enable"] false osConfig;
  osCursorEnabled = lib.attrByPath ["fnltochkaLib" "themes" "cursor" "enable"] false osConfig;
  osCursorPackage = lib.attrByPath ["fnltochkaLib" "themes" "cursor" "package"] pkgs.bibata-cursors osConfig;
  osCursorName = lib.attrByPath ["fnltochkaLib" "themes" "cursor" "name"] "Bibata-Modern-Classic" osConfig;
  osCursorSize = lib.attrByPath ["fnltochkaLib" "themes" "cursor" "size"] 24 osConfig;

  isRu = lib.hasPrefix "ru" osLocale;
  homeDir = config.home.homeDirectory;

  dirs =
    if isRu
    then {
      desktop = "${homeDir}/Рабочий стол";
      documents = "${homeDir}/Документы";
      download = "${homeDir}/Загрузки";
      music = "${homeDir}/Музыка";
      pictures = "${homeDir}/Изображения";
      publicShare = "${homeDir}/Общедоступные";
      templates = "${homeDir}/Шаблоны";
      videos = "${homeDir}/Видео";
    }
    else {
      desktop = "${homeDir}/Desktop";
      documents = "${homeDir}/Documents";
      download = "${homeDir}/Downloads";
      music = "${homeDir}/Music";
      pictures = "${homeDir}/Pictures";
      publicShare = "${homeDir}/Public";
      templates = "${homeDir}/Templates";
      videos = "${homeDir}/Videos";
    };

  templateFile =
    if isRu
    then "Шаблоны/Текстовый документ.txt"
    else "Templates/Text Document.txt";
in {
  programs.zsh = lib.mkIf osZshEnabled {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    defaultKeymap = "emacs";
    history = {
      size = 100000;
      save = 100000;
      append = true;
      extended = true;
      share = true;
      ignoreAllDups = true;
    };
    setOptions = [
      "HIST_REDUCE_BLANKS"
      "HIST_VERIFY"
      "INC_APPEND_HISTORY"
    ];
    oh-my-zsh = {
      enable = true;
      theme = "ys";
      plugins = [
        "git"
        "sudo"
        "extract"
      ];
      extraConfig = ''
        for km in emacs viins; do
          bindkey -M "$km" '^?' backward-delete-char
          bindkey -M "$km" '^H' backward-kill-word
        done
      '';
    };
  };

  dconf.settings = lib.mkIf osGnomeEnabled {
    "org/gnome/desktop/peripherals/touchpad" = {
      disable-while-typing = false;
    };
    "org/gnome/desktop/interface" = {
      show-battery-percentage = true;
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      command = "kgx";
      binding = "<Super>r";
    };
    "org/gnome/shell/extensions/blur-my-shell" = {
      hacks-level = 0;
    };
    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      blur = false;
    };
  };

  home = {
    pointerCursor = lib.mkIf (osDesktopEnabled && osCursorEnabled) {
      package = osCursorPackage;
      name = osCursorName;
      size = osCursorSize;
      gtk.enable = true;
      x11.enable = true;
    };

    activation.updateXdgUserDirs = lib.mkIf osDesktopEnabled (lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update
    '');

    file.${templateFile} = lib.mkIf osDesktopEnabled {
      text = "";
    };
  };

  xdg.userDirs = lib.mkIf osDesktopEnabled {
    enable = true;
    createDirectories = true;
    inherit (dirs) desktop;
    inherit (dirs) documents;
    inherit (dirs) download;
    inherit (dirs) music;
    inherit (dirs) pictures;
    inherit (dirs) publicShare;
    inherit (dirs) templates;
    inherit (dirs) videos;
  };
}
