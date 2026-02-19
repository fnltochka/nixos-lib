{
  config,
  lib,
  pkgs,
  ...
}: let
  hmEnabled = config.fnltochkaLib.system.home-manager.enable or false;

  accountSubmodule = {name, ...}: {
    options = {
      /**
      Enable this user account.

      When enabled, creates a normal user account with the specified configuration.
      */
      enable = lib.mkEnableOption "user account ${name}";

      /**
      User description/comment.

      Default: username

      Used as the user's GECOS field.
      */
      description = lib.mkOption {
        type = lib.types.str;
        default = name;
      };

      /**
      Additional groups for this user.

      Default: []

      Groups are merged with defaultNormalUserExtraGroups and wheel (if isAdmin).
      */
      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      /**
      Whether this user is an administrator.

      Default: false

      If true, adds the user to the wheel group (for sudo access).
      */
      isAdmin = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "If true, add wheel group by default.";
      };

      /**
      User's login shell.

      Default: pkgs.zsh if fnltochkaLib.system.zsh.enable is true, otherwise pkgs.bash

      The shell package to use for this user.
      */
      shell = lib.mkOption {
        type = lib.types.package;
        default = pkgs.zsh;
        description = "Login shell. Defaults to zsh if fnltochkaLib.system.zsh.enable is true, otherwise bash.";
      };

      /**
      Home Manager module for this user.

      Default: null

      Path to a Home Manager module that configures this user's home directory.
      Requires `fnltochkaLib.system.home-manager.enable = true`.
      */
      homeModule = lib.mkOption {
        type = lib.types.nullOr lib.types.deferredModule;
        default = null;
        description = "Home Manager module for this user.";
      };

      /**
      SSH authorized keys for this user.

      Default: fnltochkaLib.users.sshKeys

      List of SSH public keys that can be used to authenticate as this user.
      */
      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = config.fnltochkaLib.users.sshKeys;
      };
    };
  };

  enabledAccounts = lib.filterAttrs (_: u: u.enable) config.fnltochkaLib.users.accounts;
in {
  /**
  User accounts configuration.

  Defines user accounts with their properties. Each account can have:
  - enable: Enable the account
  - description: User description
  - extraGroups: Additional groups
  - isAdmin: Add to wheel group
  - shell: Login shell
  - homeModule: Home Manager configuration
  - authorizedKeys: SSH public keys

  # Example

  ```nix
  fnltochkaLib.users.accounts.user = {
    enable = true;
    description = "Regular User";
    isAdmin = false;
    extraGroups = ["networkmanager"];
    homeModule = ./home-manager/users/user.nix;
  };

  fnltochkaLib.users.accounts.admin = {
    enable = true;
    isAdmin = true;
    description = "System Administrator";
  };
  ```
  */
  options.fnltochkaLib.users.accounts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule accountSubmodule);
    default = {};
  };

  config = let
    zshEnabled = config.fnltochkaLib.system.zsh.enable or false;
    defaultShell =
      if zshEnabled
      then pkgs.zsh
      else pkgs.bash;
    # Check if shell is zsh by checking package name
    isZsh = shell: (shell.pname or "") == "zsh" || (toString shell) == toString pkgs.zsh;
  in {
    users.users = lib.mapAttrs' (username: u:
      lib.nameValuePair username (lib.mkMerge [
        {
          isNormalUser = true;
          createHome = true;
          inherit (u) description;
          extraGroups = lib.unique (
            config.fnltochkaLib.users.defaultNormalUserExtraGroups
            ++ u.extraGroups
            ++ (lib.optionals u.isAdmin ["wheel"])
          );
          openssh.authorizedKeys.keys = u.authorizedKeys;
        }
        {
          shell = lib.mkForce (
            if isZsh u.shell && !zshEnabled
            then defaultShell
            else u.shell
          );
        }
      ]))
    enabledAccounts;

    home-manager.users =
      lib.mkIf hmEnabled
      (lib.mapAttrs' (username: u:
        lib.nameValuePair username u.homeModule)
      (lib.filterAttrs (_: u: u.homeModule != null) enabledAccounts));
  };
}
