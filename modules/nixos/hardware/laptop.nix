{
  config,
  lib,
  ...
}:
let
  cfg = config.fnltochkaLib.hardware.laptop;
in
{
  options.fnltochkaLib.hardware.laptop.enable = lib.mkEnableOption "laptop power + input defaults";

  config = lib.mkIf cfg.enable {
    services = {
      tlp.enable = true;
      power-profiles-daemon.enable = lib.mkForce false;
      upower.enable = true;
      logind.settings.Login.HandleLidSwitch = "suspend";
      libinput.enable = true;
    };
  };
}
