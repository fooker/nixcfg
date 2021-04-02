{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./peering.nix
    ./backup.nix
    ./hive.nix
  ];
}