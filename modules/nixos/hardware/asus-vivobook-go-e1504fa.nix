{
  config,
  lib,
  ...
}: let
  cfg = config.fnltochkaLib.hardware.asusVivobookGoE1504fa;
in {
  options.fnltochkaLib.hardware.asusVivobookGoE1504fa.enable =
    lib.mkEnableOption "ASUS Vivobook Go E1504FA hardware profile";

  config = lib.mkIf cfg.enable {
    fnltochkaLib.hardware.laptop.enable = lib.mkDefault true;

    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "uas"
      "sd_mod"
    ];

    boot.kernelModules = ["kvm-amd"];

    hardware.enableRedistributableFirmware = lib.mkDefault true;
    hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  };
}
