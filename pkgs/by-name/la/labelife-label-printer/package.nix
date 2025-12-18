{ lib
, stdenv
, fetchurl
, cups
, autoPatchelfHook
, detox
}:

stdenv.mkDerivation {
  pname = "labelife-label-printer";
  version = "2.0.0.004";

  src = fetchurl {
    url = "https://oss.qu-in.ltd/Labelife/Label_Printer_Driver_Linux.zip";
    hash = "sha256-toFOTFs6xMhzEGvJ7yUYAK1aRcQyGcL55ObfwPVN4iE=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    detox
    # unzip & tar are in stdenv by default
  ];

  buildInputs = [ cups ];

  unpackPhase = ''
    runHook preUnpack

    unzip $src
    tar -xzf Label_Printer_Driver_Linux.tar.gz
    tar -xf Label_Printer_Driver_Linux.tar

    cd LabelPrinter-2.0.0.004

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    detox ppds

    install -Dm755 x86_64/rastertolabeltspl \
      $out/lib/cups/filter/rastertolabeltspl

    for ppd in ppds/*.ppd; do
      install -Dm644 "$ppd" \
        $out/share/cups/model/label/$(basename "$ppd")
    done

    runHook postInstall
  '';

  meta = {
    description = "CUPS driver for Labelife-compatible thermal label printers";
    homepage = "https://labelife.net";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "armv7l-linux"
      "i686-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
