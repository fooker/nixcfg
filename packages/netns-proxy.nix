{ rustPlatform, inputs, ... }:

rustPlatform.buildRustPackage rec {
  name = "netns-proxy";

  src = inputs.netns-proxy;

  cargoHash = "sha256-BUatbymNQDOjjBq/d3RzbqJbjDjikQvkeiDbGUvwDH8=";
}
