{
  config,
  lib,
  ...
}:
let
  cfg = config.fnltochkaLib.roles.server;
in
{
  /**
    Enable server role.

    Server role includes minimal server configuration:
    - Base role: All base system configuration
    - SSH: OpenSSH service with secure defaults

    **Important**: SSH is configured with `PasswordAuthentication = false`.
    Ensure SSH keys are configured before deploying:
    ```nix
    fnltochkaLib.users.sshKeys = ["ssh-ed25519 AAAA... user@example"];
    fnltochkaLib.users.accounts.admin = {
      enable = true;
      isAdmin = true;
    };
    ```

    # Example

    ```nix
    fnltochkaLib.roles.server.enable = true;
    fnltochkaLib.services.ssh.port = 4422;
    ```
  */
  options.fnltochkaLib.roles.server.enable = lib.mkEnableOption "server role (base+SSH)";

  config = lib.mkIf cfg.enable {
    fnltochkaLib = {
      roles.base.enable = true;
      roles.base.development.enable = false;
      services.ssh.enable = true;
    };
  };
}
