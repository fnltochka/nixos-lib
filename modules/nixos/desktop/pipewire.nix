{
  config,
  lib,
  ...
}: let
  cfg = config.fnltochkaLib.desktop;
in {
  /**
  Enable PipeWire audio system.

  Requires: `fnltochkaLib.desktop.enable = true`

  Replaces PulseAudio with PipeWire, providing:
  - ALSA support for legacy applications
  - PulseAudio compatibility layer
  - Better audio latency and quality

  # Example

  ```nix
  fnltochkaLib.desktop.enable = true;
  fnltochkaLib.desktop.pipewire.enable = true;
  ```
  */
  options.fnltochkaLib.desktop.pipewire.enable = lib.mkEnableOption "PipeWire audio";

  config = lib.mkIf (cfg.enable && cfg.pipewire.enable) {
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
}
