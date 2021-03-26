{ stdenv, rustPlatform, fetchFromGitHub, ... }:

let
  sources = import ../nix/sources.nix;

in rustPlatform.buildRustPackage {
  name = "ipinfo";

  src = sources.ipinfo;

  cargoSha256 = "19rvnxxj4rp88zj2fr1i8s980sybq2g3c77m9ql4baqd5sldcfrc";
}
