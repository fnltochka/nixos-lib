{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fnltochkaLib.vpn.networkManagerPlugins;
in {
  options.fnltochkaLib.vpn.networkManagerPlugins.enable =
    lib.mkEnableOption "NetworkManager VPN plugins set";

  config = lib.mkIf cfg.enable {
    networking.networkmanager.plugins = with pkgs; [
      networkmanager-fortisslvpn
      networkmanager-iodine
      networkmanager-l2tp
      networkmanager-openconnect
      networkmanager-openvpn
      networkmanager-sstp
      networkmanager-strongswan
      networkmanager-vpnc
    ];

    # Workaround for NixOS 25.05 / unstable issue (NixOS/nixpkgs#375352)
    # where strongSwan/charon fails an integrity test if /etc/strongswan.conf is missing
    # or not to its liking when started by nm-l2tp-service.
    environment.etc."strongswan.conf".text = "";
  };
}
