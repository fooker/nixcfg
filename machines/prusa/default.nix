{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./octoprint.nix
  ];

  serial.enable = true;
  server.enable = true;

  dns.host = {
    realm = "home";
    ipv4 = "172.23.200.132";
    ipv6 = "fd79:300d:6056:100::3";
  };
}
