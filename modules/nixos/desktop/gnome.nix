{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fnltochkaLib.desktop;
in {
  /**
  Enable GNOME desktop environment.

  Requires: `fnltochkaLib.desktop.enable = true`

  Enables full GNOME desktop with:
  - GNOME desktop environment with GDM display manager
  - Essential GNOME extensions:
    - dash-to-dock, blur-my-shell, vitals
    - app-icons-taskbar, clipboard-indicator
    - systemd-manager, ip-finder, and more
  - GNOME utilities: tweaks, extension-manager, firmware
  - KDE Connect via gsconnect extension
  - Excludes bloatware (tour, maps, music, weather, etc.)

  # Example

  ```nix
  fnltochkaLib.desktop.enable = true;
  fnltochkaLib.desktop.gnome.enable = true;
  ```
  */
  options.fnltochkaLib.desktop.gnome.enable = lib.mkEnableOption "GNOME desktop";

  config = lib.mkIf (cfg.enable && cfg.gnome.enable) {
    services = {
      xserver.enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config.common = {
        default = ["gtk" "gnome"];
        "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
        "org.freedesktop.impl.portal.RemoteDesktop" = ["gnome"];
      };
      # GNOME portal for screencast/remote-desktop, GTK as generic fallback.
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
    };

    # .d.mts (TS decls) misdetected as video/mp2t → metadata errors in node_modules.
    services.gnome.localsearch.enable = false;
    services.gnome.tinysparql.enable = false;

    environment = {
      # Nautilus preview / metadata needs extra codecs (e.g. MKV).
      sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
        gst-plugins-good
        gst-plugins-bad
        gst-plugins-ugly
        gst-libav
      ]);

      gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-maps
        gnome-music
        gnome-weather
        geary
        epiphany
        gnome-system-monitor
      ];

      systemPackages = with pkgs; [
        wsdd # gvfs wsdd:// needs this for SMB discovery.
        file-roller
        mission-center
        gnome-firmware
        gnome-extension-manager
        gnome-tweaks
        xorg.xprop
        gnomeExtensions.appindicator
        gnomeExtensions.legacy-gtk3-theme-scheme-auto-switcher
        gnomeExtensions.do-not-disturb-while-screen-sharing-or-recording
        gnomeExtensions.alttab-scroll-workaround
        gnomeExtensions.bluetooth-battery-meter
        gnomeExtensions.notification-timeout
        gnomeExtensions.quick-lang-switch
        gnomeExtensions.reboottouefi
        gnomeExtensions.privacy-settings-menu
        gnomeExtensions.vitals
        gnomeExtensions.ip-finder
        gnomeExtensions.app-icons-taskbar
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.status-area-horizontal-spacing
        gnomeExtensions.systemd-manager
        gnomeExtensions.blur-my-shell
        gnomeExtensions.app-grid-wizard
        gnomeExtensions.gtile
        gnomeExtensions.perfect-fit
        gnomeExtensions.dash-to-dock
      ];
    };

    programs.dconf.enable = true;
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    services.fwupd.enable = true;
    services.gnome.gnome-keyring.enable = true;

    security.pam.services.swaylock = {};
  };
}
