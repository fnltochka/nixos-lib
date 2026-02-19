{
  lib,
  osConfig ? {},
  ...
}: let
  osDesktopEnabled = lib.attrByPath ["fnltochkaLib" "desktop" "enable"] false osConfig;
in {
  imports = lib.optionals osDesktopEnabled [
    ../misc/xdg.nix
  ];
}
