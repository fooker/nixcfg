{ rustPlatform, inputs, ... }:

rustPlatform.buildRustPackage {
  name = "qd";

  src = inputs.qd;

  cargoHash = "sha256-TuF4fUOf4lNV/MXEER5rc7tYOppN4b46uNxRs1iVEW4=";
}
