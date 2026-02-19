{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fnltochkaLib.desktop;
in {
  /**
  Enable desktop baseline infrastructure.

  This module provides common desktop infrastructure required for desktop environments:
  - earlyoom: Memory management to prevent system freezes
  - nix-alien: Run binaries without rebuild
  - uinput: Support for input devices
  - rtkit: Real-time scheduling for audio/video
  - zramSwap: 50% memory swap with zstd compression
  - Plymouth: Boot splash screen
  - AppImage: Support for AppImage applications
  - Wayland: Electron apps support via NIXOS_OZONE_WL
  - Avahi: mDNS/DNS-SD for .local hostnames and local network discovery

  When enabled, sub-options (gnome, pipewire, flatpak, nixLd, sunshine) are enabled by default.

  # Example

  ```nix
  fnltochkaLib.desktop.enable = true;
  ```
  */
  options.fnltochkaLib.desktop.enable = lib.mkEnableOption "desktop baseline";

  /**
  Enable Flatpak support.

  Requires: `fnltochkaLib.desktop.enable = true`

  Enables Flatpak service for installing and managing Flatpak applications.

  # Example

  ```nix
  fnltochkaLib.desktop.enable = true;
  fnltochkaLib.desktop.flatpak.enable = true;
  ```
  */
  options.fnltochkaLib.desktop.flatpak.enable = lib.mkEnableOption "Flatpak support";

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      fnltochkaLib = {
        desktop = {
          gnome.enable = lib.mkDefault true;
          pipewire.enable = lib.mkDefault true;
          flatpak.enable = lib.mkDefault true;
          nixLd.enable = lib.mkDefault true;
          sunshine.enable = lib.mkDefault true;
        };
        system.nixAlien.enable = lib.mkDefault true;
        users.defaultNormalUserExtraGroups = ["uinput"];
      };
      services.earlyoom.enable = lib.mkDefault true;
      hardware.uinput.enable = true;

      security.rtkit.enable = true;

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
      };

      boot.initrd.systemd.enable = true;
      boot.plymouth.enable = true;

      programs = {
        appimage = {
          enable = true;
          binfmt = true;
        };
        obs-studio = {
          enable = true;
          enableVirtualCamera = true;
          plugins = with pkgs.obs-studio-plugins; [
            obs-vaapi
            obs-pipewire-audio-capture
            obs-vkcapture
            obs-shaderfilter
            obs-move-transition
            obs-multi-rtmp
            waveform
          ];
        };
        throne = {
          enable = true;
          tunMode.enable = true;
          tunMode.setuid = true;
        };
      };

      environment.systemPackages = with pkgs; [
        keepassxc
        easyeffects
      ];

      # nssmdns6 off: IPv6 mDNS often causes resolution timeouts.
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = false;
        openFirewall = true;
        publish = {
          enable = true;
          domain = true;
          userServices = true;
        };
      };
    })
    (lib.mkIf (cfg.enable && cfg.flatpak.enable) {
      services.flatpak.enable = true;
    })
  ];
}
