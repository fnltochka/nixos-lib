{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fnltochkaLib.desktop;
in {
  /**
  Enable nix-ld for running binaries with dynamic libraries.

  Requires: `fnltochkaLib.desktop.enable = true`

  nix-ld allows running binaries that require dynamic libraries without rebuilding them.
  Configures common libraries: stdenv.cc.cc, zlib, openssl, fuse3.

  # Example

  ```nix
  fnltochkaLib.desktop.enable = true;
  fnltochkaLib.desktop.nixLd.enable = true;
  ```
  */
  options.fnltochkaLib.desktop.nixLd.enable = lib.mkEnableOption "nix-ld support";

  config = lib.mkIf (cfg.enable && cfg.nixLd.enable) {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        openssl
        fuse3
      ];
    };
  };
}
