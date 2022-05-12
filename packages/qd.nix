{ rustPlatform, inputs, ... }:

rustPlatform.buildRustPackage rec {
  name = "qd";

  src = inputs.qd;

  cargoSha256 = "0vhijmcb6lfwp0xbxqadk8x5ifvkdcg13i65ziam7qlz8dypiqaf";
}
