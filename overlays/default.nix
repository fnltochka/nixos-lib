self: final: prev: {
  cups-brother-dcp1510r = final.callPackage ../pkgs/cups-brother-dcp1510r/package.nix {};

  unstable = self.unstablePkgs (prev.stdenv.hostPlatform.system or prev.system);
}
