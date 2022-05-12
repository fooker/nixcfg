{ rustPlatform, inputs, ... }:

rustPlatform.buildRustPackage {
  name = "ipinfo";

  src = inputs.ipinfo;

  cargoSha256 = "1zmdsaqqikmfdis836jmyzf7938zi63f1g7nshag420xfsf9jaf9";
}
