# fnltochkaLib

Personal NixOS/Home Manager module collection. Mostly for my machines; copy what is useful.

## Use

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    fnltochkaLib = {
      url = "github:fnltochka/nixos-lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, fnltochkaLib, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit fnltochkaLib; };
      modules = [
        fnltochkaLib.nixosModules.default
        ./hosts/myhost
      ];
    };
  };
}
```

Then enable modules in the host config:

```nix
{
  fnltochkaLib = {
    system.nix.enable = true;
    roles.base.enable = true;
    desktop = {
      enable = true;
      gnome.enable = true;
    };
  };
}
```

The overlay is optional: `inputs.fnltochkaLib.overlays.default`.

## What Is Inside

- NixOS modules under `fnltochkaLib.system`, `desktop`, `hardware`, `roles`, `services`, `users`, `virtualisation`, `networking.vpn`, `apps`, and `themes`.
- Home Manager modules exposed through `fnltochkaLib.lib.homeManagerModules`.
- A small overlay with `unstable` and local packages.
- Generated option docs: [`docs/complete.md`](docs/complete.md).

Some hardware modules are machine/device-specific. Read the module before enabling it.

## Development

```bash
make fmt        # nixfmt-tree
make lint       # deadnix + statix
make check      # fmt-check + lint + nix flake check
```

## License

MIT. See [`LICENSE`](LICENSE).
