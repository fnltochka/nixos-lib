# Home Manager integration module
#
# Integrates Home Manager into NixOS:
# - Enables Home Manager NixOS module
# - Configures useGlobalPkgs and useUserPackages
# - Passes inputs and osConfig to Home Manager modules
#
# Required if using fnltochkaLib.users.accounts.<user>.homeModule
{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.fnltochkaLib.system.home-manager;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  /**
  Enable Home Manager integration.

  Integrates Home Manager into NixOS configuration:
  - Enables Home Manager NixOS module
  - Configures useGlobalPkgs and useUserPackages
  - Passes inputs and osConfig to Home Manager modules for cross-referencing

  Required if using `fnltochkaLib.users.accounts.<user>.homeModule` to configure user home directories.

  # Example

  ```nix
  fnltochkaLib.system.home-manager.enable = true;

  fnltochkaLib.users.accounts.user = {
    enable = true;
    homeModule = ./home-manager/users/user.nix;
  };
  ```
  */
  options.fnltochkaLib.system.home-manager.enable = lib.mkEnableOption "Home Manager integration";

  config = lib.mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs;
        osConfig = config;
      };

      # Configure backup for existing files that would be clobbered
      # This is especially important for existing users whose home directories
      # were created before Home Manager was configured
      backupFileExtension = "backup";
    };
  };
}
