{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./backhaul.nix
    ../.
  ];

  server.enable = true;

  hive = {
    enable = true;
  };

  backup = {
    enable = true;
    passphrase = secrets.backup.passphrase;
  };

  dns.host = {
    ipv4 = "37.120.172.185";
    ipv6 = "2a03:4000:6:701e::";
  };
}
