{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fnltochkaLib.apps.devtools;
in {
  /**
  Enable developer tools package set.

  Comprehensive development environment with:
  - Common CLI tools: git, docker, direnv, jq, nix tools, etc.
  - Language toolchains: Rust, Go, JVM (Java/Kotlin), Node.js, Python
  - Development utilities: compilers, debuggers, build tools
  - Optional: Android Studio

  Most sub-options have sensible defaults. Enable only what you need.

  # Example

  ```nix
  fnltochkaLib.apps.devtools.enable = true;
  fnltochkaLib.apps.devtools.rust.enable = true;
  fnltochkaLib.apps.devtools.go.enable = true;
  fnltochkaLib.apps.devtools.nodejs.enable = true;
  ```
  */
  options.fnltochkaLib.apps.devtools = {
    enable = lib.mkEnableOption "Developer tools";

    /**
    Enable common developer CLI tools.

    Installs essential development tools:
    - Version control: git, git-lfs, gh
    - Nix tools: alejandra, deadnix, nixd, nil, nixpkgs-fmt, statix
    - Build tools: docker, direnv, gnumake, just
    - Utilities: jq, yq, buf, protobuf, openapi-generator-cli
    - Code tools: code-cursor, pre-commit

    Enabled by default when devtools are enabled.
    */
    tools.enable = lib.mkEnableOption "Common developer CLI tools";

    /**
    Enable extra developer toolbox.

    Installs additional tools:
    - Compilers: gcc, clang, rustc, cargo, llvm
    - Build systems: cmake, meson, ninja, autotools
    - Debuggers: gdb, lldb
    - Sysops tools: nmap, tcpdump, android-tools, scrcpy
    - Misc: meld, tmux, wireguard-tools

    Disabled by default.
    */
    extra.enable = lib.mkEnableOption "Extra developer toolbox (compilers + sysops + misc)";

    /**
    Enable Rust toolchain.

    Installs: rustc, cargo

    Disabled by default.
    */
    rust.enable = lib.mkEnableOption "Rust toolchain";

    /**
    Enable Go toolchain.

    Installs: go

    Disabled by default.
    */
    go.enable = lib.mkEnableOption "Go toolchain";

    /**
    Enable Go development tooling.

    Requires: `fnltochkaLib.apps.devtools.go.enable = true`

    Installs: gopls, golangci-lint, gofumpt, golines, gotools, goose, mockgen, revive, sqlc

    Enabled by default when Go is enabled.
    */
    go.tools.enable = lib.mkEnableOption "Go tooling (gopls, linters, formatters, etc.)";

    /**
    Enable JVM (Java + Kotlin) toolchain.

    Installs: JDK (default: jdk21), kotlin, gradle

    Disabled by default.
    */
    jvm.enable = lib.mkEnableOption "Java + Kotlin toolchain";

    /**
    Enable Android Studio.

    Installs: android-studio IDE

    Disabled by default.
    */
    androidStudio.enable = lib.mkEnableOption "Android Studio";

    /**
    Enable Python 3.

    Installs: python3, pip

    Disabled by default.
    */
    python.enable = lib.mkEnableOption "Python 3";

    /**
    Node.js runtime and tooling.

    - enable: Node.js (default nodejs_22), TypeScript, typescript-language-server. Default when devtools enabled.
    - tools.enable: pnpm, yarn, npm-check-updates, vite. Requires nodejs.enable. Default when Node.js enabled.
    - package: Node.js package (default nodejs_22). Override for different version.
    */
    nodejs = {
      enable = lib.mkEnableOption "Node.js runtime";
      tools.enable = lib.mkEnableOption "Node.js tooling (package managers + common CLIs)";
      package = lib.mkPackageOption pkgs "nodejs_22" {};
    };

    /**
    JDK package to use.

    Default: jdk21

    Can be overridden to use a different JDK version.
    */
    jvm.jdkPackage = lib.mkPackageOption pkgs "jdk21" {};

    /**
    Enable database tools.

    Installs common database clients and utilities:
    - PostgreSQL: psql client (via postgresql)
    - MySQL/MariaDB: mysql client
    - SQLite: sqlite
    - Redis: redis
    - MongoDB: mongosh
    - GUI client: dbeaver-bin

    Disabled by default.
    */
    databases.enable = lib.mkEnableOption "Database tools (clients + GUI)";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      fnltochkaLib = {
        apps.devtools = {
          tools.enable = lib.mkDefault true;
          extra.enable = lib.mkDefault false;
          rust.enable = lib.mkDefault false;
          go.enable = lib.mkDefault false;
          go.tools.enable = lib.mkDefault true;
          jvm.enable = lib.mkDefault false;
          androidStudio.enable = lib.mkDefault false;
          nodejs.enable = lib.mkDefault true;
          nodejs.tools.enable = lib.mkDefault true;
          python.enable = lib.mkDefault false;
          databases.enable = lib.mkDefault false;
        };
      };
    }
    (lib.mkIf cfg.tools.enable {
      programs.direnv.enable = true;

      environment.systemPackages = with pkgs; [
        alejandra
        buf
        inputs.code-cursor-nix.packages.${system}.cursor
        deadnix
        docker
        gh
        git
        git-lfs
        gnumake
        jq
        just
        niv
        nix-eval-jobs
        nix-fast-build
        nix-prefetch-scripts
        nix-prefetch-git
        nixd
        nil
        nix-output-monitor
        nixpkgs-fmt
        nixdoc
        deploy-rs
        openapi-generator-cli
        pre-commit
        protobuf
        statix
        yq
      ];
    })
    (lib.mkIf cfg.extra.enable {
      environment.systemPackages = with pkgs; [
        # compilers
        autoconf
        automake
        cargo
        ccache
        clang
        cmake
        gcc
        gdb
        lldb
        llvm
        libtool
        meson
        nasm
        ninja
        pkg-config
        rustc

        # sysops/tools
        android-tools
        busybox
        curl
        ffmpeg-full
        htop
        liboping
        mc
        meld
        nano
        nmap
        parted
        ripgrep
        rsync
        scrcpy
        shared-mime-info
        speedtest-cli
        tcpdump
        tmux
        wget
        wireguard-tools
        xz
        zip
        unzip
      ];
    })
    (lib.mkIf cfg.rust.enable {
      environment.systemPackages = with pkgs; [
        rustc
        cargo
      ];
    })
    (lib.mkIf cfg.go.enable {
      environment.systemPackages =
        (with pkgs; [go])
        ++ lib.optionals cfg.go.tools.enable (with pkgs; [
          gofumpt
          golangci-lint
          golines
          gopls
          gotools
          goose
          mockgen
          revive
          sqlc
        ]);
    })
    (lib.mkIf cfg.jvm.enable {
      environment.systemPackages = with pkgs; [
        cfg.jvm.jdkPackage
        kotlin
        gradle
      ];
    })
    (lib.mkIf cfg.androidStudio.enable {
      environment.systemPackages = with pkgs; [
        android-studio
      ];
    })
    (lib.mkIf cfg.nodejs.enable {
      environment.systemPackages =
        [
          cfg.nodejs.package
        ]
        ++ (with pkgs.nodePackages; [
          typescript
          typescript-language-server
        ])
        ++ lib.optionals cfg.nodejs.tools.enable (with pkgs; [
          npm-check-updates
          vite
        ])
        ++ lib.optionals cfg.nodejs.tools.enable (with pkgs.nodePackages; [
          pnpm
          yarn
        ]);
    })
    (lib.mkIf cfg.databases.enable {
      environment.systemPackages = with pkgs; [
        postgresql
        #mariadb.client
        #sqlite
        #redis
        #mongosh
        dbeaver-bin
      ];
    })
    (lib.mkIf cfg.python.enable {
      environment.systemPackages = with pkgs; [
        python3
        python3Packages.pip
      ];
    })
  ]);
}
