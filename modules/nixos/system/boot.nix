# Boot configuration module
#
# Sets up:
# - systemd-boot (default)
# - EFI variables access (default)
# - Latest kernel packages (linuxPackages_latest, default)
#
# Can be overridden per-host if needed (e.g., for LTS kernel).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.fnltochkaLib.system.boot;
in
{
  /**
    Enable boot configuration defaults.

    Sets up bootloader and kernel:
    - systemd-boot: UEFI bootloader (default)
    - EFI variables access: Allows modifying EFI variables (default)
    - Latest kernel packages: linuxPackages_latest (default)

    Can be overridden per-host if needed. For example, NVIDIA drivers may require LTS kernel:
    ```nix
    boot.kernelPackages = pkgs.linuxPackages;  # LTS kernel
    ```

    # Example

    ```nix
    fnltochkaLib.system.boot.enable = true;
    ```
  */
  options.fnltochkaLib.system.boot.enable = lib.mkEnableOption "bootloader + kernel defaults";

  config = lib.mkIf cfg.enable {
    boot = {
      loader.systemd-boot.enable = lib.mkDefault true;
      loader.efi.canTouchEfiVariables = lib.mkDefault true;
      kernelPackages = lib.mkDefault pkgs.linuxPackages_6_18;
    };
  };
}
