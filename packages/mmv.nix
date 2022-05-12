{ rustPlatform, inputs, ... }:

rustPlatform.buildRustPackage rec {
  name = "mmv";

  src = inputs.mmv;

  cargoSha256 = "12x2m28kn2zl7ks06q88qq7wvarw30vid50sl8l3zlrj1azf4br9";
}
