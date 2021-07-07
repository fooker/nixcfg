{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./peering.nix
    ./dns/default.nix
    ./syncthing.nix
  ];

  server.enable = true;

  hive = {
    enable = true;
  };

  backup.passphrase = secrets.backup.passphrase;

  dns.host = {
    ipv4 = "37.120.161.15";
    ipv6 = "2a03:4000:6:30f2::";
  };
}
