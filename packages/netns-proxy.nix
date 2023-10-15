{ rustPlatform, inputs, ... }:

rustPlatform.buildRustPackage rec {
  name = "netns-proxy";

  src = inputs.netns-proxy;

  cargoSha256 = "sha256-BUatbymNQDOjjBq/d3RzbqJbjDjikQvkeiDbGUvwDH8=";
}
