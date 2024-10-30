{ pkgs
, fetchFromGitHub
, makeRustPlatform
, pkg-config
, alsa-lib
, ...
}:

let
  rust-overlay = pkgs.extend (import (fetchFromGitHub {
    owner = "oxalica";
    repo = "rust-overlay";
    rev = "master";
    hash = "sha256-xGP95+G2/esys6FpxrunwwfhirfGsFfPKBJ12MLV1Ps=";
  }));

  rust-bin = rust-overlay.rust-bin.nightly."2024-10-11".minimal;

  rust-platform = makeRustPlatform {
    cargo = rust-bin;
    rustc = rust-bin;
  };

in
rust-platform.buildRustPackage {
  name = "photonic-scene";

  src = ./scene;

  cargoLock = {
    lockFile = ./scene/Cargo.lock;
    outputHashes = {
      "photonic-0.1.0" = "sha256-6iRxnJ61A3d5cuvf0A+9c3aDzdzWeZ/+T5LZLljIZYw=";
    };
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
  ];
}

