{ config, lib, pkgs, ... }:

{
  imports = [
    ./rpi3.nix
    ./cryptroot.nix
  ];
}
