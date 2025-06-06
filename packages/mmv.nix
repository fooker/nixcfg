{ rustPlatform, inputs, ... }:

rustPlatform.buildRustPackage {
  name = "mmv";

  src = inputs.mmv;

  cargoHash = "sha256-s6ehQ6maMLHDJzqy/rWGbMhr6P2jf0cWR0lfTYG0Nmk=";
}
