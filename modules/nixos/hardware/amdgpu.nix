{
  config,
  lib,
  ...
}: let
  cfg = config.fnltochkaLib.hardware.amdgpu;
in {
  options = {
    fnltochkaLib.hardware.amdgpu = {
      enable = lib.mkEnableOption "AMD GPU defaults";
      corectrl.enable = lib.mkEnableOption "CoreCtrl";
      overdrive.enable = lib.mkEnableOption "AMDGPU overdrive";
    };
  };

  config = lib.mkIf cfg.enable {
    fnltochkaLib.hardware.amdgpu = {
      corectrl.enable = lib.mkDefault true;
      overdrive.enable = lib.mkDefault true;
    };

    programs.corectrl.enable = lib.mkIf cfg.corectrl.enable true;
    hardware.amdgpu.overdrive.enable = lib.mkIf cfg.overdrive.enable true;
  };
}
