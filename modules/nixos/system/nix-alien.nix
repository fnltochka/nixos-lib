{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.fnltochkaLib.system.nixAlien;
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  /**
    Enable nix-alien for running foreign binaries.

    Allows running binaries that weren't built for NixOS without rebuilding them.
    Uses nix-ld and nix-alien wrapper to handle dynamic library loading.

    # Example

    ```nix
    fnltochkaLib.system.nixAlien.enable = true;
    ```
  */
  options.fnltochkaLib.system.nixAlien.enable =
    lib.mkEnableOption "nix-alien (run foreign binaries on NixOS)";

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = lib.mkDefault true;

    environment.systemPackages = [
      inputs.nix-alien.packages.${system}.nix-alien
    ];
  };
}
