{
  config,
  lib,
  ...
}:
let
  cfg = config.fnltochkaLib.system.networking;
in
{
  /**
    Enable baseline networking defaults.

    Configures essential networking services:
    - NetworkManager: Network connection management
    - Firewall: Basic firewall protection
    - systemd-resolved: DNS resolution
    - TCP congestion control: BBR (default)
    - IP forwarding: Optional (disabled by default)

    # Example

    ```nix
    fnltochkaLib.system.networking.enable = true;
    fnltochkaLib.system.networking.ipForwarding.enable = true;
    ```
  */
  options.fnltochkaLib.system.networking = {
    enable = lib.mkEnableOption "baseline networking defaults";

    ipForwarding = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable IP forwarding (for routers/gateways)";
      };

      ipv4 = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable IPv4 forwarding (when ipForwarding is enabled)";
      };

      ipv6 = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable IPv6 forwarding (when ipForwarding is enabled)";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      networking.networkmanager.enable = lib.mkDefault true;
      networking.firewall.enable = lib.mkDefault true;
      services.resolved.enable = lib.mkDefault true;

      boot.kernel.sysctl = {
        "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";
      };
    })
    (lib.mkIf (cfg.enable && cfg.ipForwarding.enable) {
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = lib.mkDefault (if cfg.ipForwarding.ipv4 then 1 else 0);
        "net.ipv6.conf.all.forwarding" = lib.mkDefault (if cfg.ipForwarding.ipv6 then 1 else 0);
      };
    })
  ];
}
