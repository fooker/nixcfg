{ lib, pkgs, sources, ... }:

with lib;

let
  ipinfo = pkgs.callPackage ../packages/ipinfo.nix { inherit sources; };

in input: importJSON (pkgs.runCommand "ipinfo-json" {} ''
    ${ipinfo}/bin/ipinfo -j "${input}" > $out
  '')
