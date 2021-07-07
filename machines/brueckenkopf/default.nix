{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./peering.nix
    ./weechat.nix
    ./monitoring
  ];

  server.enable = true;

  backup.passphrase = secrets.backup.passphrase;

  dns.host = {
    ipv4 = "193.174.29.6";
    ipv6 = "2001:638:301:11a3::6";
  };
}
