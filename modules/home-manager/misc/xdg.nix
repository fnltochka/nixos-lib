{
  lib,
  pkgs,
  ...
}:
let
  defaultApplicationPackages = [
    pkgs.gnome-text-editor
    pkgs.loupe
    pkgs.totem
  ];

  mutableMimeAppsList =
    pkgs.runCommand "mutable-mimeapps.list" { ps = defaultApplicationPackages; }
      ''
        export PATH=$PATH:${pkgs.crudini}/bin

        printf '%s\n\n%s\n' '[Added Associations]' '[Default Applications]' > "$out"

        mergeEntry() {
          local mime="$1"
          local name="$2"
          local existing

          existing="$(crudini --get "$out" 'Default Applications' "$mime" 2>/dev/null || true)"
          local value="$existing''${existing:+;}''$name"
          crudini --ini-options=nospace --inplace --set "$out" 'Default Applications' "$mime" "$value"
        }

        for p in $ps; do
          for path in "$p"/share/applications/*.desktop; do
            name="''${path##*/}"
            mimes="$(crudini --get "$path" 'Desktop Entry' MimeType 2>/dev/null || true)"
            for mime in ''${mimes//;/ }; do
              mergeEntry "$mime" "$name"
            done
          done
        done
      '';
in
{
  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.activation.seedMutableMimeApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
    data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
    config_mime="$config_home/mimeapps.list"
    legacy_mime="$data_home/applications/mimeapps.list"
    seed_mime_apps=false

    if [[ -L "$config_mime" ]]; then
      config_mime_target="$(${pkgs.coreutils}/bin/readlink -m "$config_mime" 2>/dev/null || true)"
      case "$config_mime_target" in
        /nix/store/*) seed_mime_apps=true ;;
      esac
    elif [[ ! -e "$config_mime" ]]; then
      seed_mime_apps=true
    fi

    if [[ "$seed_mime_apps" == true ]]; then
      run mkdir -p $VERBOSE_ARG "$config_home"
      run rm -f $VERBOSE_ARG "$config_mime"
      run install -m 0644 $VERBOSE_ARG ${mutableMimeAppsList} "$config_mime"
    fi

    if [[ -L "$legacy_mime" ]]; then
      legacy_mime_target="$(${pkgs.coreutils}/bin/readlink -m "$legacy_mime" 2>/dev/null || true)"
      case "$legacy_mime_target" in
        /nix/store/*) run rm -f $VERBOSE_ARG "$legacy_mime" ;;
      esac
    fi
  '';
}
