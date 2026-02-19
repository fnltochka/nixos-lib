{
  lib,
  stdenvNoCC,
  pkgsi686Linux,
  fetchurl,
  cups,
  dpkg,
  gnused,
  makeWrapper,
  ghostscript,
  file,
  a2ps,
  coreutils,
  gawk,
  patchelf,
}: let
  version = "3.0.1-1";
  cupsdeb = fetchurl {
    url = "https://download.brother.com/welcome/dlf100458/dcp1510cupswrapper-${version}.i386.deb";
    hash = "sha256-edEKkB9VJlLIrQ7/YKfSo+A5EfmnEEcd8GxppGd2vKo=";
  };
  lprdeb = fetchurl {
    url = "https://download.brother.com/welcome/dlf100455/dcp1510lpr-${version}.i386.deb";
    hash = "sha256-VgT8jIgPwj9HUp5B76/dRnnerYqFmq6gxD1oZrxxUOc=";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "cups-brother-dcp1510r";
    inherit version;

    srcs = [
      cupsdeb
      lprdeb
    ];

    nativeBuildInputs = [
      makeWrapper
    ];

    buildInputs = [
      cups
      ghostscript
      dpkg
      a2ps
      patchelf
    ];

    unpackPhase = ''
      runHook preUnpack

      dpkg-deb -x ${lprdeb} $out
      dpkg-deb -x ${cupsdeb} $out

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/cups/filter $out/share/cups/model

      ln -s \
        $out/opt/brother/Printers/DCP1510/cupswrapper/brother_lpdwrapper_DCP1510 \
        $out/lib/cups/filter/brother_lpdwrapper_DCP1510

      ln -s \
        $out/opt/brother/Printers/DCP1510/cupswrapper/brother-DCP1510-cups-en.ppd \
        $out/share/cups/model/

      ln -s \
        $out/opt/brother/Printers/DCP1510/cupswrapper/brcupsconfig4 \
        $out/lib/cups/filter/brcupsconfig4

      runHook postInstall
    '';

    postFixup = ''
      substituteInPlace $out/opt/brother/Printers/DCP1510/lpd/filter_DCP1510 \
        --replace-fail /opt "$out/opt"

      sed -i '/GHOST_SCRIPT=/c\\GHOST_SCRIPT=gs' $out/opt/brother/Printers/DCP1510/lpd/psconvert2

      patchelf --set-interpreter ${pkgsi686Linux.glibc.out}/lib/ld-linux.so.2 $out/opt/brother/Printers/DCP1510/lpd/brprintconflsr3
      patchelf --set-interpreter ${pkgsi686Linux.glibc.out}/lib/ld-linux.so.2 $out/opt/brother/Printers/DCP1510/lpd/rawtobr3
      patchelf --set-interpreter ${pkgsi686Linux.glibc.out}/lib/ld-linux.so.2 $out/opt/brother/Printers/DCP1510/inf/braddprinter

      wrapProgram $out/opt/brother/Printers/DCP1510/lpd/psconvert2 \
        --prefix PATH ":" ${
        lib.makeBinPath [
          gnused
          coreutils
          gawk
        ]
      }

      wrapProgram $out/opt/brother/Printers/DCP1510/lpd/filter_DCP1510 \
        --prefix PATH ":" ${
        lib.makeBinPath [
          ghostscript
          a2ps
          file
          gnused
          coreutils
        ]
      }

      substituteInPlace $out/opt/brother/Printers/DCP1510/cupswrapper/brother_lpdwrapper_DCP1510 \
        --replace-fail /opt "$out/opt"

      wrapProgram $out/opt/brother/Printers/DCP1510/cupswrapper/brother_lpdwrapper_DCP1510 \
        --prefix PATH ":" ${
        lib.makeBinPath [
          gnused
          coreutils
          gawk
        ]
      }
    '';

    meta = {
      homepage = "http://www.brother.com/";
      description = "Brother DCP-1510R printer driver (CUPS + LPR wrapper)";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      license = lib.licenses.unfreeRedistributable;
      platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
    };
  }
