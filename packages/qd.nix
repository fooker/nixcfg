{ rustPlatform, ... }:

let
  sources = import ../nix/sources.nix;

in rustPlatform.buildRustPackage rec {
  name = "qd";

  src = sources.qd;

  cargoSha256 = "1hakklx7yjkcmmlig5whdhz9xx7lic69mw5n3xlqk7wx3fwaby5x";
}
