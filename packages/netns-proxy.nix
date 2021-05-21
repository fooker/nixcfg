{ rustPlatform, ... }:

let
  sources = import ../nix/sources.nix;

in rustPlatform.buildRustPackage rec {
  name = "netns-proxy";

  src = sources.netns-proxy;

  cargoSha256 = "0695ah7qxf7m43f2n1rvryyvgbmqk0i4lvq7smr1dqvyz7qhjsg4";
}
