{lib, ...}: {
  /**
  Default SSH public keys for all users.

  Default: []

  These keys are used as the default for all user accounts unless overridden
  in the account's authorizedKeys option.

  # Example

  ```nix
  fnltochkaLib.users.sshKeys = [
    "ssh-ed25519 AAAA... user@example"
    "ssh-rsa AAAA... user@example"
  ];
  ```
  */
  options.fnltochkaLib.users.sshKeys = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Default SSH public keys for admin users";
  };

  /**
  Extra groups automatically added to every normal user.

  Default: []

  These groups are added to all users created via fnltochkaLib.users.accounts,
  in addition to any groups specified in the account's extraGroups.

  # Example

  ```nix
  fnltochkaLib.users.defaultNormalUserExtraGroups = ["networkmanager" "audio"];
  ```
  */
  options.fnltochkaLib.users.defaultNormalUserExtraGroups = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Extra groups automatically added to every isNormalUser user.";
  };
}
