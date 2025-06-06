{ rustPlatform, inputs, ... }:

rustPlatform.buildRustPackage rec {
  name = "netns-proxy";

  src = inputs.netns-proxy;

  cargoHash = "sha256-hipkC49aY/imChfcJyaiFhC+BxetSe0Sm5j6vXW45AM=";
}
