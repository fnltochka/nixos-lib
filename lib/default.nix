_: {
  # Helper for consumers who want to construct a host in a single place.
  mkHost =
    {
      hostname,
      system ? "x86_64-linux",
      nixpkgs,
      modules,
      specialArgs ? { },
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = modules ++ [ { networking.hostName = hostname; } ];
      specialArgs = specialArgs // {
        inherit hostname;
      };
    };

  homeManagerModules = {
    base = import ../modules/home-manager/base.nix;

    misc = {
      xdg = import ../modules/home-manager/misc/xdg.nix;
    };

    bundles = {
      desktopUi = import ../modules/home-manager/bundles/desktop-ui.nix;
    };
  };
}
