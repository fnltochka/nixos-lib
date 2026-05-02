{
  description = "Reusable NixOS + Home Manager modules (fnltochkaLib.*) by fnltochka";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    {
      lib = import ./lib { inherit (inputs.nixpkgs) lib; };

      overlays.default = import ./overlays/default.nix self;

      nixosModules.default = import ./modules/nixos;

      registryUnstableFlake = inputs.nixpkgs-unstable;

      unstablePkgs =
        system:
        import inputs.nixpkgs-unstable.outPath {
          inherit system;
          config.allowUnfree = true;
        };
    };
}
