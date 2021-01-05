{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./backhaul.nix
    ./hive.nix
  ];
}