{ rustPlatform, ... }:

let
  sources = import ../nix/sources.nix;

in
rustPlatform.buildRustPackage rec {
  name = "qd";

  src = sources.qd;

  cargoSha256 = "0vhijmcb6lfwp0xbxqadk8x5ifvkdcg13i65ziam7qlz8dypiqaf";
}
