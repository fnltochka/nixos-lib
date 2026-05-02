{
  config,
  lib,
  ...
}:
let
  cfg = config.fnltochkaLib.hardware.asusX409faBv625;
in
{
  options.fnltochkaLib.hardware.asusX409faBv625.enable =
    lib.mkEnableOption "ASUS X409FA-BV625 hardware profile";

  config = lib.mkIf cfg.enable {
    fnltochkaLib.hardware.laptop.enable = lib.mkDefault true;

    boot = {
      initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_usb_sdmmc"
      ];

      kernelModules = [ "kvm-intel" ];

      # Common Realtek 8821CE WiFi module (safe default for this model).
      extraModulePackages = [
        config.boot.kernelPackages.rtl8821ce
      ];
    };

    hardware = {
      enableRedistributableFirmware = lib.mkDefault true;
      cpu.intel.updateMicrocode = lib.mkDefault true;
    };
  };
}
