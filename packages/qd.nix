{ rustPlatform, inputs, ... }:

rustPlatform.buildRustPackage {
  name = "qd";

  src = inputs.qd;

  cargoHash = "sha256-4y0arj6x6l+DQ8G+cVOtAWeCXZ4qVvK2nD48oMwSas8=";
}
