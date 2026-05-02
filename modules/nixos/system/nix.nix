# Nix configuration module
#
# Configures:
# - Enables flakes and nix-command experimental features
# - Sets allowUnfree = true
# - Automatic garbage collection (weekly, deletes older than 30 days)
# - Automatic store optimization (weekly)
# - Applies fnltochkaLib overlays
# - Optionally: registryUnstable — add nixpkgs-unstable to nix registry (built into fnltochkaLib)
#
# This is typically required for most configurations.
{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.fnltochkaLib.system.nix;
in
{
  /**
    Enable Nix configuration defaults.

    Configures essential Nix settings:
    - Enables flakes and nix-command experimental features
    - Sets allowUnfree = true for proprietary packages
    - Automatic garbage collection: weekly, deletes packages older than 30 days
    - Automatic store optimization: weekly
    - Applies fnltochkaLib overlays
    - Configures substituters: cache.nixos.org and nix-community.cachix.org
    - Optionally: registryUnstable — add nixpkgs-unstable to nix registry (for nix run nixpkgs-unstable#pkg; uses the flake built into fnltochkaLib)

    This is typically required for most configurations using this library.

    # Example

    ```nix
    fnltochkaLib.system.nix.enable = true;
    ```
  */
  options.fnltochkaLib.system.nix.enable =
    lib.mkEnableOption "Nix defaults (flakes, GC, allowUnfree)";

  options.fnltochkaLib.system.nix.registryUnstable = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = "Add nixpkgs-unstable to nix registry (e.g. nix run nixpkgs-unstable#pkg).";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      nixpkgs.overlays = [
        inputs.fnltochkaLib.overlays.default
      ];

      nixpkgs.config.allowUnfree = true;

      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://cuda-maintainers.cachix.org"
            "https://cache.garnix.io"
            "https://hyprland.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
            "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          ];
        };

        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };

        optimise = {
          automatic = true;
          dates = [ "weekly" ];
        };
      };
    })
    (lib.mkIf cfg.registryUnstable {
      nix.registry.nixpkgs-unstable.flake = inputs.fnltochkaLib.registryUnstableFlake;
    })
  ];
}
