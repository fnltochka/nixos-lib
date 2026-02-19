# fnltochkaLib

Reusable NixOS + Home Manager modules under `fnltochkaLib.*`. Enable via `fnltochkaLib.<path>.enable = true`.

> [!WARNING]
> This is a personal config shared as-is, like many others. It is not intended for production or “proper” library use — use at your own risk, and feel free to copy or fork what you need.

## Setup

Add the flake to your `inputs` and pass `fnltochkaLib` in `specialArgs`; in your host config, import the default module.

**Example `flake.nix`:**

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    fnltochkaLib = {
      url = "github:fnltochka/nixos-lib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fnltochkaLib, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = { inherit fnltochkaLib; };
        modules = [
          fnltochkaLib.nixosModules.default
          home-manager.nixosModules.default
        ];
      };
    };
}
```

**In your host config** (e.g. `hosts/myhost/default.nix`):

```nix
{ config, fnltochkaLib, ... }:
{
  imports = [ fnltochkaLib.nixosModules.default ];

  fnltochkaLib = {
    system.base.enable = true;
    desktop.gnome.enable = true;
    # ...
  };
}
```

**Overlay** (optional): `inputs.fnltochkaLib.overlays.default` adds packages (including `unstable`) and the Brother DCP-1510R package. Only use if you need those.

## Flake inputs

The library declares inputs; in your flake use `follows` to supply your own versions.

| Input | Required | Description |
|-------|----------|-------------|
| `nixpkgs` | yes | Nixpkgs (nixos-25.11 or your channel) |
| `nixpkgs-unstable` | no | For overlay `unstable` and `registryUnstableFlake` |
| `home-manager` | if using HM | For Home Manager modules |
| `nix-alien` | no | For `fnltochkaLib.system.nix-alien` |
| `code-cursor-nix` | no | For Cursor/IDE integration in devtools |

## Modules

Options and paths: [docs/complete.md](docs/complete.md).

| Category | Path / option | Generic | Description |
|----------|---------------|---------|-------------|
| **system** | `fnltochkaLib.system.*` | yes | boot, locale, nix, networking, home-manager, zsh, nix-alien |
| **services** | `fnltochkaLib.services.*` | yes | ssh |
| **virtualisation** | `fnltochkaLib.virtualisation.*` | yes | docker |
| **desktop** | `fnltochkaLib.desktop.*` | yes | base, gnome, pipewire, nix-ld, sunshine |
| **apps** | `fnltochkaLib.apps.*` | yes | devtools, wine |
| **roles** | `fnltochkaLib.roles.*` | yes | base, desktop, server |
| **networking/vpn** | `fnltochkaLib.networking.vpn.*` | yes | Amnezia kernel, NetworkManager plugins |
| **hardware** | `fnltochkaLib.hardware.*` | partial | amdgpu, nvidia, laptop, printing, scanning, vmPve — generic |
| **hardware (device-specific)** | `fnltochkaLib.hardware.*` | no | brother-dcp1510r, asus-x409fa-bv625, asus-vivobook-go-e1504fa, macbook-pro-2012, kinect-xbox360 — for specific devices |
| **users** | `fnltochkaLib.users.*` | yes | accounts, sshKeys options, etc. |
| **themes** | `fnltochkaLib.themes.*` | yes | themes |

Some modules target the author’s specific hardware; use only what you need.

## Checks

```bash
make check
```

Runs `fmt-check` (Alejandra), `lint` (deadnix, statix), and `nix flake check`. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
