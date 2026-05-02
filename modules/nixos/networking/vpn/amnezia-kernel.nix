{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.fnltochkaLib.vpn.amnezia.kernel;
in
{
  options.fnltochkaLib.vpn.amnezia.kernel.enable =
    lib.mkEnableOption "amneziawg kernel module + CLI tools";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      amneziawg-go
      amneziawg-tools
    ];

    boot.extraModulePackages = with config.boot.kernelPackages; [
      amneziawg
    ];
    boot.kernelModules = [
      "amneziawg"
    ];
  };
}
