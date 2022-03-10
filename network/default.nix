{ lib, ... }:

with lib;

{
  imports = [
    ./sites.nix
    ./devices.nix
    ./prefixes.nix
  ];
}
