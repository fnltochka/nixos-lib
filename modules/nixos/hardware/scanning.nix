{
  config,
  lib,
  ...
}: let
  cfg = config.fnltochkaLib.hardware.scanning;
in {
  options.fnltochkaLib.hardware.scanning.enable = lib.mkEnableOption "scanner support (SANE)";
  options.fnltochkaLib.hardware.scanning.brscan4.enable = lib.mkEnableOption "Brother brscan4 support";

  config = lib.mkIf cfg.enable {
    hardware.sane.enable = true;
    hardware.sane.brscan4.enable = cfg.brscan4.enable;
  };
}
