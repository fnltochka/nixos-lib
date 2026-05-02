{
  config,
  lib,
  ...
}:
let
  cfg = config.fnltochkaLib.roles.desktop;
in
{
  /**
    Enable desktop role.

    Desktop role includes complete desktop system setup:
    - Base role: All base system configuration
    - Desktop: GNOME, PipeWire, Flatpak, nix-ld, Sunshine
    - SSH: OpenSSH service
    - Does not install user-space GUI apps by default (use Home Manager)

    Individual modules can still be overridden or extended after enabling the role.

    # Example

    ```nix
    fnltochkaLib.roles.desktop.enable = true;

    # Extend
    fnltochkaLib.apps.wine.enable = true;
    ```
  */
  options.fnltochkaLib.roles.desktop.enable = lib.mkEnableOption "desktop role (base+desktop+SSH)";

  config = lib.mkIf cfg.enable {
    fnltochkaLib = {
      roles.base.enable = true;
      desktop.enable = true;
      services.ssh.enable = true;
    };
  };
}
