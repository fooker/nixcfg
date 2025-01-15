{ craneLib
, pkgs
, ...
}:

craneLib.buildPackage {
  src = craneLib.cleanCargoSource (craneLib.path ./scene);

  strictDeps = true;

  nativeBuildInputs = with pkgs; [
    pkg-config
    protobuf
  ];

  buildInputs = with pkgs; [
    openssl
    alsa-lib
    lua5_4
  ];
}

