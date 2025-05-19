{ rustPlatform, inputs, ... }:

rustPlatform.buildRustPackage {
  name = "mmv";

  src = inputs.mmv;

  cargoHash = "sha256-KS/ivgoy0z8oohqUFjcYPKvND8YIYQP0PPQLO5Gooos=";
}
