{ rustPlatform, ... }:

let
  sources = import ../nix/sources.nix;

in
rustPlatform.buildRustPackage {
  name = "ipinfo";

  src = sources.ipinfo;

  cargoSha256 = "1zmdsaqqikmfdis836jmyzf7938zi63f1g7nshag420xfsf9jaf9";
}
