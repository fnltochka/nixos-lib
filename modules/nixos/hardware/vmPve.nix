# Proxmox VE guest profile (fnltochkaLib.hardware.vmPve)
#
# Enables qemu-guest-style config and virtio for NixOS running as a VM on Proxmox.
# Inlines boot.initrd from NixOS qemu-guest profile (no cross-module imports).
{
  config,
  lib,
  ...
}: let
  cfg = config.fnltochkaLib.hardware.vmPve;
in {
  options.fnltochkaLib.hardware.vmPve.enable = lib.mkEnableOption "Proxmox VE guest (qemu-guest, virtio)";

  config = lib.mkIf cfg.enable {
    boot = {
      initrd.availableKernelModules = [
        "uhci_hcd"
        "ehci_pci"
        "ahci"
        "virtio_pci"
        "virtio_scsi"
        "virtio_net"
        "virtio_mmio"
        "virtio_blk"
        "9p"
        "9pnet_virtio"
        "sd_mod"
        "sr_mod"
      ];
      initrd.kernelModules = [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
        "virtio_gpu"
      ];
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
    };

    swapDevices = [];

    services = {
      qemuGuest.enable = true;
      spice-vdagentd.enable = true;
    };

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
