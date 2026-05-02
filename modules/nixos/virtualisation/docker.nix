{
  config,
  lib,
  ...
}:
let
  cfg = config.fnltochkaLib.virtualisation.docker;
in
{
  /**
    Enable Docker container runtime.

    Configures Docker with:
    - Docker daemon enabled
    - Automatic pruning of unused images/containers
    - docker-compose tool installed

    # Example

    ```nix
    fnltochkaLib.virtualisation.docker.enable = true;
    ```
  */
  options.fnltochkaLib.virtualisation.docker.enable = lib.mkEnableOption "Docker";

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.autoPrune.enable = true;
    #environment.systemPackages = with pkgs; [docker-compose];
  };
}
