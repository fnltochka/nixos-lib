{
  config,
  lib,
  ...
}:
let
  cfg = config.fnltochkaLib.services.ssh;
in
{
  /**
    Enable OpenSSH service.

    Configures OpenSSH server with secure defaults:
    - PasswordAuthentication = false (key-based only)
    - PermitRootLogin = no (configurable via permitRootLogin option)

    **Important**: Ensure SSH keys are configured before enabling:
    ```nix
    fnltochkaLib.users.sshKeys = ["ssh-ed25519 AAAA... user@example"];
    ```

    # Example

    ```nix
    fnltochkaLib.services.ssh.enable = true;
    fnltochkaLib.services.ssh.permitRootLogin = "prohibit-password";
    ```
  */
  options = {
    fnltochkaLib.services.ssh = {
      enable = lib.mkEnableOption "OpenSSH service";

      /**
        Permit root login via SSH.

        Default: "no"

        Controls whether root can log in via SSH. Valid values:
        - "no": Root login is not permitted
        - "yes": Root login is permitted (not recommended)
        - "prohibit-password": Root login is permitted only with key-based authentication
        - "forced-commands-only": Root login is permitted only for forced commands

        # Example

        ```nix
        fnltochkaLib.services.ssh.permitRootLogin = "prohibit-password";
        ```
      */
      permitRootLogin = lib.mkOption {
        type = lib.types.enum [
          "no"
          "yes"
          "prohibit-password"
          "forced-commands-only"
        ];
        default = "prohibit-password";
        description = "Whether to permit root login via SSH";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 22;
        description = "Port for OpenSSH daemon";
      };

      fail2ban = lib.mkEnableOption "fail2ban for SSH (sshd jail)";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      openssh = {
        enable = true;
        ports = [ cfg.port ];
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = cfg.permitRootLogin;
          KbdInteractiveAuthentication = false;
          ChallengeResponseAuthentication = false;
          AllowTcpForwarding = true;
          MaxAuthTries = 6;
          UsePAM = true;
          LoginGraceTime = "30s";
          ClientAliveInterval = 300;
          ClientAliveCountMax = 2;
        };
      };
      fail2ban = lib.mkIf cfg.fail2ban {
        enable = true;
        bantime = "1h";
        maxretry = 3;
        jails.sshd.enabled = true;
      };
    };
  };
}
