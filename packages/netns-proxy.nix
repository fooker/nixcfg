{ rustPlatform, inputs, ... }:

rustPlatform.buildRustPackage rec {
  name = "netns-proxy";

  src = inputs.netns-proxy;

  cargoSha256 = "0brc5damxcrszcijw79jlgs4zjmihd0mqf65qns7f20sq997pvzj";
}
