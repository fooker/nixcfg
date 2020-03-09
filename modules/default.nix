{ config, lib, pkgs, ... }:

{
  imports = [
    ./common/default.nix
    ./boot/default.nix
    ./server.nix
    ./serial.nix
    ./backhaul/default.nix
  ];
}