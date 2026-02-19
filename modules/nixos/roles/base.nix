{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fnltochkaLib.roles.base;
in {
  /**
  Enable base role.

  Base role includes essential system configuration:
  - Boot: systemd-boot, EFI variables, latest kernel
  - Nix: flakes, GC, allowUnfree, overlays
  - Networking: NetworkManager, firewall, resolved
  - Zsh: Zsh shell configuration
  - Locale: timezone and locale settings
  - Home Manager: Home Manager integration

  This role is typically included by other roles (desktop, server).

  # Example

  ```nix
  fnltochkaLib.roles.base.enable = true;
  ```
  */
  options.fnltochkaLib.roles.base = {
    enable = lib.mkEnableOption "base role (boot+nix+networking+zsh+locale+HM)";

    /**
    Enable terminal UX package group.

    Includes modern CLI UX tools like eza/fzf/btop.
    */
    terminalUx.enable = lib.mkEnableOption "terminal UX tools";

    /**
    Enable diagnostics and networking package group.

    Includes troubleshooting tools like strace/tcpdump/iperf3.
    */
    diagnostics.enable = lib.mkEnableOption "diagnostics and networking tools";

    /**
    Enable generic development helpers package group.

    Includes tools like python3/shellcheck/lazygit/httpie.
    */
    development.enable = lib.mkEnableOption "development helper tools";

    /**
    Enable Nix-specific tooling package group.

    Includes formatter/linters and deploy/secret tools for Nix workflows.
    */
    nixTools.enable = lib.mkEnableOption "Nix development tools";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      fnltochkaLib = {
        roles.base = {
          terminalUx.enable = lib.mkDefault true;
          diagnostics.enable = lib.mkDefault true;
          development.enable = lib.mkDefault true;
          nixTools.enable = lib.mkDefault true;
        };

        system = {
          boot.enable = true;
          nix.enable = true;
          networking.enable = true;
          zsh.enable = true;
          locale.enable = true;
          home-manager.enable = true;
        };
      };
      programs.mtr.enable = true;

      # Minimal “repair kit” available system-wide.
      environment.systemPackages = with pkgs; [
        # Core
        bat
        busybox
        cloud-utils
        curl
        file
        git
        gnumake
        jq
        nano
        openssl
        ripgrep
        rsync
        tmux
        tree
        unzip
        wget
        zip
      ];
    }
    (lib.mkIf cfg.terminalUx.enable {
      environment.systemPackages = with pkgs; [
        # Navigation and terminal UX
        eza
        fd
        fzf
        htop
        mc
        neofetch
        tldr
        zoxide
        btop
        procs
      ];
    })
    (lib.mkIf cfg.diagnostics.enable {
      environment.systemPackages = with pkgs; [
        # Diagnostics and networking
        dust
        duf
        ncdu
        strace
        dnsutils
        dogdns
        iperf3
        nload
        tcpdump
        lnav
      ];
    })
    (lib.mkIf cfg.development.enable {
      environment.systemPackages = with pkgs; [
        # Development helpers
        httpie
        gitui
        python3
        shellcheck
        delta
        xh
        libgcc
        jdk21_headless
      ];
    })
    (lib.mkIf cfg.nixTools.enable {
      environment.systemPackages = with pkgs; [
        # Nix
        alejandra
        deadnix
        statix
        sops
        age
        ssh-to-age
        nixdoc
        nix-prefetch-git
        nix-tree
        deploy-rs
        pkg-config
      ];
    })
  ]);
}
