{ rustPlatform, ... }:

let
  sources = import ../nix/sources.nix;

in rustPlatform.buildRustPackage rec {
  name = "mmv";

  src = sources.mmv;

  cargoSha256 = "1vy6jidhwv14gf7zqll9fa1p3asin798zgavyn7rk9m2583p1bx4";
}
