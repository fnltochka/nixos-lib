{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.fnltochkaLib.system.zsh;
  hmEnabled = config.fnltochkaLib.system.home-manager.enable or false;
in {
  /**
  Enable system-wide Zsh defaults.

  Configures Zsh as the default shell:
  - Enables Zsh program
  - Sets root user shell to Zsh
  - Configures zsh with oh-my-zsh for root via Home Manager (if home-manager is enabled)

  # Example

  ```nix
  fnltochkaLib.system.zsh.enable = true;
  fnltochkaLib.system.home-manager.enable = true;
  ```
  */
  options.fnltochkaLib.system.zsh.enable = lib.mkEnableOption "system-wide zsh defaults";

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.zsh.enable = true;
      users.users.root.shell = pkgs.zsh;
    })
    (lib.mkIf (cfg.enable && hmEnabled) {
      home-manager.users.root = {
        imports = [
          inputs.fnltochkaLib.lib.homeManagerModules.base
        ];
        home = {
          username = "root";
          homeDirectory = "/root";
          inherit (config.system) stateVersion;
        };
      };
    })
  ];
}
