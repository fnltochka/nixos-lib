# fnltochkaLib - Complete Module Reference

This document is automatically generated from doc-comments in the source code using [nixdoc](https://github.com/nix-community/nixdoc).

**Last generated:** 2026-02-19T06:40:37+03:00

---

## Table of Contents

- [System Modules](#system-modules)
  - [Nix Configuration](#fnltochkalibsystemnixenable)
  - [Boot Configuration](#fnltochkalibsystembootenable)
  - [Home Manager Integration](#fnltochkalibhomemanagerenable)
  - [Networking](#fnltochkalibsystemnetworkingenable)
  - [Zsh Shell](#fnltochkalibsystemzshenable)
  - [Nix-Alien](#fnltochkalibsystemnixalienenable)
- [Desktop Modules](#desktop-modules)
  - [Desktop Baseline](#fnltochkalibdesktopenable)
  - [GNOME](#fnltochkalibdesktopgnomeenable)
  - [PipeWire](#fnltochkalibdesktoppipewireenable)
  - [Flatpak](#fnltochkalibdesktopflatpakenable)
  - [Nix-LD](#fnltochkalibdesktopnixldenable)
  - [Sunshine](#fnltochkalibdesktopsunshineenable)
- [Apps Modules](#apps-modules)
  - [Workstation](#fnltochkalibappsworkstationenable)
  - [Browsers](#fnltochkalibappsbrowsersenable)
  - [Communications](#fnltochkalibappscommunicationsenable)
  - [Office](#fnltochkalibappsofficeenable)
  - [Media](#fnltochkalibappsmediaenable)
  - [Developer Tools](#fnltochkalibappsdevtoolsenable)
  - [Networking](#fnltochkalibappsnetworkingenable)
  - [Security](#fnltochkalibappssecurityenable)
  - [Utilities](#fnltochkalibappsutilitiesenable)
  - [VPN](#fnltochkalibappsvpnenable)
  - [Wine](#fnltochkalibappswineenable)
- [Services Modules](#services-modules)
  - [SSH](#fnltochkalibservicessshenable)
  - [EarlyOOM](#fnltochkalibservicesearlyoomenable)
- [Users Modules](#users-modules)
  - [User Accounts](#fnltochkalibusersaccounts)
  - [SSH Keys](#fnltochkalibuserssshkeys)
  - [Default Groups](#fnltochkalibusersdefaultnormaluserextragroups)
- [Bundles](#bundles)
  - [Desktop Standard](#fnltochkalibbundlesdesktopstandardenable)
  - [Server Base](#fnltochkalibbundlesserverbaseenable)
- [Virtualisation Modules](#virtualisation-modules)
  - [Docker](#fnltochkalibvirtualisationdockerenable)

---

# System Modules {#system-modules}
## Nix Configuration
Enable Nix configuration defaults.

Configures essential Nix settings:
- Enables flakes and nix-command experimental features
- Sets allowUnfree = true for proprietary packages
- Automatic garbage collection: weekly, deletes packages older than 30 days
- Automatic store optimization: weekly
- Applies fnltochkaLib overlays
- Configures substituters: cache.nixos.org and nix-community.cachix.org
- Optionally: registryUnstable — add nixpkgs-unstable to nix registry (for nix run nixpkgs-unstable#pkg; uses the flake built into fnltochkaLib)

This is typically required for most configurations using this library.

### Example

```nix
fnltochkaLib.system.nix.enable = true;
```

## Boot Configuration
Enable boot configuration defaults.

Sets up bootloader and kernel:
- systemd-boot: UEFI bootloader (default)
- EFI variables access: Allows modifying EFI variables (default)
- Latest kernel packages: linuxPackages_latest (default)

Can be overridden per-host if needed. For example, NVIDIA drivers may require LTS kernel:
```nix
boot.kernelPackages = pkgs.linuxPackages;  # LTS kernel
```

### Example

```nix
fnltochkaLib.system.boot.enable = true;
```

## Home Manager Integration
Enable Home Manager integration.

Integrates Home Manager into NixOS configuration:
- Enables Home Manager NixOS module
- Configures useGlobalPkgs and useUserPackages
- Passes inputs and osConfig to Home Manager modules for cross-referencing

Required if using `fnltochkaLib.users.accounts.<user>.homeModule` to configure user home directories.

### Example

```nix
fnltochkaLib.system.home-manager.enable = true;

fnltochkaLib.users.accounts.user = {
  enable = true;
  homeModule = ./home-manager/users/user.nix;
};
```

## Networking
Enable baseline networking defaults.

Configures essential networking services:
- NetworkManager: Network connection management
- Firewall: Basic firewall protection
- systemd-resolved: DNS resolution
- TCP congestion control: BBR (default)
- IP forwarding: Optional (disabled by default)

### Example

```nix
fnltochkaLib.system.networking.enable = true;
fnltochkaLib.system.networking.ipForwarding.enable = true;
```

## Zsh Shell
Enable system-wide Zsh defaults.

Configures Zsh as the default shell:
- Enables Zsh program
- Sets root user shell to Zsh
- Configures zsh with oh-my-zsh for root via Home Manager (if home-manager is enabled)

### Example

```nix
fnltochkaLib.system.zsh.enable = true;
fnltochkaLib.system.home-manager.enable = true;
```

## Nix-Alien
Enable nix-alien for running foreign binaries.

Allows running binaries that weren't built for NixOS without rebuilding them.
Uses nix-ld and nix-alien wrapper to handle dynamic library loading.

### Example

```nix
fnltochkaLib.system.nixAlien.enable = true;
```

# Desktop Modules {#desktop-modules}
## Desktop Baseline
Enable desktop baseline infrastructure.

This module provides common desktop infrastructure required for desktop environments:
- earlyoom: Memory management to prevent system freezes
- nix-alien: Run binaries without rebuild
- uinput: Support for input devices
- rtkit: Real-time scheduling for audio/video
- zramSwap: 50% memory swap with zstd compression
- Plymouth: Boot splash screen
- AppImage: Support for AppImage applications
- Wayland: Electron apps support via NIXOS_OZONE_WL
- Avahi: mDNS/DNS-SD for .local hostnames and local network discovery

When enabled, sub-options (gnome, pipewire, flatpak, nixLd, sunshine) are enabled by default.

### Example

```nix
fnltochkaLib.desktop.enable = true;
```

## `options.fnltochkaLib.desktop.flatpak.enable` {#options.fnltochkaLib.desktop.flatpak.enable}

Enable Flatpak support.

Requires: `fnltochkaLib.desktop.enable = true`

Enables Flatpak service for installing and managing Flatpak applications.

### Example

```nix
fnltochkaLib.desktop.enable = true;
fnltochkaLib.desktop.flatpak.enable = true;
```

## GNOME Desktop
Enable GNOME desktop environment.

Requires: `fnltochkaLib.desktop.enable = true`

Enables full GNOME desktop with:
- GNOME desktop environment with GDM display manager
- Essential GNOME extensions:
  - dash-to-dock, blur-my-shell, vitals
  - app-icons-taskbar, clipboard-indicator
  - systemd-manager, ip-finder, and more
- GNOME utilities: tweaks, extension-manager, firmware
- KDE Connect via gsconnect extension
- Excludes bloatware (tour, maps, music, weather, etc.)

### Example

```nix
fnltochkaLib.desktop.enable = true;
fnltochkaLib.desktop.gnome.enable = true;
```

## PipeWire Audio
Enable PipeWire audio system.

Requires: `fnltochkaLib.desktop.enable = true`

Replaces PulseAudio with PipeWire, providing:
- ALSA support for legacy applications
- PulseAudio compatibility layer
- Better audio latency and quality

### Example

```nix
fnltochkaLib.desktop.enable = true;
fnltochkaLib.desktop.pipewire.enable = true;
```

## Nix-LD
Enable nix-ld for running binaries with dynamic libraries.

Requires: `fnltochkaLib.desktop.enable = true`

nix-ld allows running binaries that require dynamic libraries without rebuilding them.
Configures common libraries: stdenv.cc.cc, zlib, openssl, fuse3.

### Example

```nix
fnltochkaLib.desktop.enable = true;
fnltochkaLib.desktop.nixLd.enable = true;
```

## Sunshine
Enable Sunshine game streaming host.

Requires: `fnltochkaLib.desktop.enable = true`

Sunshine is a self-hosted game stream host for Moonlight.
Configures with autoStart, capSysAdmin, and firewall access.

### Example

```nix
fnltochkaLib.desktop.enable = true;
fnltochkaLib.desktop.sunshine.enable = true;
fnltochkaLib.desktop.sunshine.allowWan = true;  # Optional: allow WAN access
```

## `options.fnltochkaLib.desktop.sunshine.allowWan` {#options.fnltochkaLib.desktop.sunshine.allowWan}

Allow WAN access to Sunshine web UI.

Requires: `fnltochkaLib.desktop.sunshine.enable = true`

By default, Sunshine web UI is only accessible from LAN.
Enable this to allow access from WAN.

# Apps Modules {#apps-modules}
## Developer Tools
Enable developer tools package set.

Comprehensive development environment with:
- Common CLI tools: git, docker, direnv, jq, nix tools, etc.
- Language toolchains: Rust, Go, JVM (Java/Kotlin), Node.js, Python
- Development utilities: compilers, debuggers, build tools
- Optional: Android Studio

Most sub-options have sensible defaults. Enable only what you need.

### Example

```nix
fnltochkaLib.apps.devtools.enable = true;
fnltochkaLib.apps.devtools.rust.enable = true;
fnltochkaLib.apps.devtools.go.enable = true;
fnltochkaLib.apps.devtools.nodejs.enable = true;
```

## Wine
# Services Modules {#services-modules}
## SSH Service
Enable OpenSSH service.

Configures OpenSSH server with secure defaults:
- PasswordAuthentication = false (key-based only)
- PermitRootLogin = no (configurable via permitRootLogin option)

**Important**: Ensure SSH keys are configured before enabling:
```nix
fnltochkaLib.users.sshKeys = ["ssh-ed25519 AAAA... user@example"];
```

### Example

```nix
fnltochkaLib.services.ssh.enable = true;
fnltochkaLib.services.ssh.permitRootLogin = "prohibit-password";
```

# Users Modules {#users-modules}
## User Options
Default SSH public keys for all users.

Default: []

These keys are used as the default for all user accounts unless overridden
in the account's authorizedKeys option.

### Example

```nix
fnltochkaLib.users.sshKeys = [
  "ssh-ed25519 AAAA... user@example"
  "ssh-rsa AAAA... user@example"
];
```

## `options.fnltochkaLib.users.defaultNormalUserExtraGroups` {#options.fnltochkaLib.users.defaultNormalUserExtraGroups}

Extra groups automatically added to every normal user.

Default: []

These groups are added to all users created via fnltochkaLib.users.accounts,
in addition to any groups specified in the account's extraGroups.

### Example

```nix
fnltochkaLib.users.defaultNormalUserExtraGroups = ["networkmanager" "audio"];
```

## User Accounts
User accounts configuration.

Defines user accounts with their properties. Each account can have:
- enable: Enable the account
- description: User description
- extraGroups: Additional groups
- isAdmin: Add to wheel group
- shell: Login shell
- homeModule: Home Manager configuration
- authorizedKeys: SSH public keys

### Example

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

# Bundles {#bundles}
# Virtualisation Modules {#virtualisation-modules}
## Docker
Enable Docker container runtime.

Configures Docker with:
- Docker daemon enabled
- Automatic pruning of unused images/containers
- docker-compose tool installed

### Example

```nix
fnltochkaLib.virtualisation.docker.enable = true;
```

---

## Additional Resources

- [README.md](../README.md) - User guide and overview
- [EXAMPLES.md](../EXAMPLES.md) - Configuration examples
- [docs/README.md](README.md) - Documentation generation guide

---

*This documentation is automatically generated. For the most up-to-date information, see the source code with doc-comments.*

