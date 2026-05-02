{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fnltochkaLib.hardware.nvidia;
  sunshineEnabled = config.fnltochkaLib.desktop.sunshine.enable or false;
in {
  /**
  Enable NVIDIA GPU support with CUDA and container toolkit.

  When enabled:
  - Enables CUDA support in nixpkgs
  - Configures OpenGL/graphics (32-bit, nvidia-vaapi-driver, cudatoolkit, libcublas)
  - Sets X server video driver to nvidia
  - Enables kernel modesetting (required for Wayland/GBM; reduces EGLImage/gnome-shell screencast errors)
  - Optionally: reducedVaSpaceWorkarounds (kernel params + Mutter software cursor) for GPUs that exhaust VA (e.g. RTX 2080); enable only on affected hosts
  - Enables nvidia-container-toolkit
  - Sets CUDA_PATH and adds CUDA packages to systemPackages
  - Overrides OBS Studio with cudaSupport
  - When Sunshine is enabled, overrides Sunshine package with cudaSupport

  For easyNvidia (VAAPI bridge, desktop presets) use an external module
  (e.g. tlater-dotfiles.nixosModules.nvidia) and set easyNvidia in the host config.

  # Example

  ```nix
  fnltochkaLib.hardware.nvidia.enable = true;
  ```
  */
  options.fnltochkaLib.hardware.nvidia.enable = lib.mkEnableOption "NVIDIA GPU (CUDA, container toolkit, OBS/Sunshine overrides)";

  /**
  Enable VA-space workarounds for GPUs that exhaust VA (e.g. RTX 2080 / Turing).
  Enables NVreg kernel params and Mutter software cursor. Leave disabled on newer GPUs.
  */
  options.fnltochkaLib.hardware.nvidia.reducedVaSpaceWorkarounds = lib.mkEnableOption "VA space workarounds (kernel params + Mutter software cursor) for affected GPUs only";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      nixpkgs.config.cudaSupport = lib.mkDefault true;

      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = with pkgs; [
            cudaPackages.cudatoolkit
            cudaPackages.libcublas
            nvidia-vaapi-driver
          ];
        };

        nvidia.package = lib.mkDefault pkgs.unstable.linuxPackages.nvidiaPackages.beta;
        nvidia.modesetting.enable = true;
        nvidia-container-toolkit.enable = true;
      };

      services.xserver.videoDrivers = ["nvidia"];

      environment = {
        sessionVariables.CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
        systemPackages = with pkgs; [
          cudaPackages.cudatoolkit
          cudaPackages.libcublas
        ];
      };

      programs.obs-studio.package = pkgs.obs-studio.override {
        cudaSupport = true;
      };
    }
    (lib.mkIf cfg.reducedVaSpaceWorkarounds {
      boot.kernelParams = [
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
        "nvidia.NVreg_EnableGpuFirmware=0"
      ];
      environment.sessionVariables.MUTTER_DEBUG_DISABLE_HW_CURSORS = "1";
    })
    (lib.mkIf sunshineEnabled {
      services.sunshine = {
        package = pkgs.sunshine.override {
          cudaSupport = true;
          inherit (pkgs) cudaPackages;
        };
      };
    })
  ]);
}
