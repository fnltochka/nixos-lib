{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.fnltochkaLib.hardware.brotherDcp1510r;
in
{
  options.fnltochkaLib.hardware.brotherDcp1510r.enable =
    lib.mkEnableOption "Brother DCP-1510R (printing + scanning)";

  config = lib.mkIf cfg.enable {
    fnltochkaLib.hardware = {
      printing.enable = true;
      printing.drivers = [
        pkgs.cups-brother-dcp1510r
      ];

      scanning.enable = true;
      scanning.brscan4.enable = true;
    };
  };
}
