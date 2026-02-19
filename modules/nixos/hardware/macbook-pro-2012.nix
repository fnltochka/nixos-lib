{
  config,
  lib,
  ...
}: let
  cfg = config.fnltochkaLib.hardware.macbookPro2012;
in {
  options.fnltochkaLib.hardware.macbookPro2012.enable =
    lib.mkEnableOption "MacBook Pro 2012 (MacBookPro9,1) hardware profile";

  config = lib.mkIf cfg.enable {
    fnltochkaLib.hardware.laptop.enable = lib.mkDefault true;

    # Conservative initrd module set; safe to keep minimal and override per-host if needed.
    boot.initrd.availableKernelModules = [
      "ahci"
      "usb_storage"
      "sd_mod"
    ];

    boot.kernelModules = ["kvm-intel"];

    hardware.enableRedistributableFirmware = lib.mkDefault true;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

    services.thermald.enable = lib.mkDefault true;
  };
}
