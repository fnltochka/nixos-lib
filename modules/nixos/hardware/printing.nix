{
  config,
  lib,
  ...
}: let
  cfg = config.fnltochkaLib.hardware.printing;
in {
  options.fnltochkaLib.hardware.printing.enable = lib.mkEnableOption "printing support";
  options.fnltochkaLib.hardware.printing.drivers = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [];
    description = "CUPS driver packages to install when printing is enabled.";
  };

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    services.printing.drivers = cfg.drivers;
  };
}
