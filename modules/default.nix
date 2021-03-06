{ config, lib, pkgs, ... }:

{
  imports = [
    ./common/default.nix
    ./boot/default.nix
    ./server.nix
    ./serial.nix
    ./backhaul/default.nix
    ./backup.nix
    ./platform/default.nix
    ./letsencrypt.nix
    ./reverse-proxy.nix
    ./firewall.nix
    ./docker.nix
    ./builder.nix
    ./hive/default.nix
  ];
}