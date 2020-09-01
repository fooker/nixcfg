{ lib, pkgs, ... }:

with lib;

let
  ipinfo = pkgs.callPackage ../packages/ipinfo.nix {};

in input: importJSON (pkgs.runCommand "ipinfo-json" {} ''
    ${ipinfo}/bin/ipinfo -j "${input}" > $out
  '')
