{
  config,
  lib,
  ...
}: let
  cfg = config.fnltochkaLib.desktop;
in {
  /**
  Enable Sunshine game streaming host.

  Requires: `fnltochkaLib.desktop.enable = true`

  Sunshine is a self-hosted game stream host for Moonlight.
  Configures with autoStart, capSysAdmin, and firewall access.

  # Example

  ```nix
  fnltochkaLib.desktop.enable = true;
  fnltochkaLib.desktop.sunshine.enable = true;
  fnltochkaLib.desktop.sunshine.allowWan = true;  # Optional: allow WAN access
  ```
  */
  options.fnltochkaLib.desktop.sunshine.enable = lib.mkEnableOption "Sunshine host";

  /**
  Allow WAN access to Sunshine web UI.

  Requires: `fnltochkaLib.desktop.sunshine.enable = true`

  By default, Sunshine web UI is only accessible from LAN.
  Enable this to allow access from WAN.
  */
  options.fnltochkaLib.desktop.sunshine.allowWan =
    lib.mkEnableOption "WAN access to Sunshine";

  config = lib.mkIf (cfg.enable && cfg.sunshine.enable) {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        origin_web_ui_allowed =
          if cfg.sunshine.allowWan
          then "wan"
          else "lan";
      };
    };
  };
}
