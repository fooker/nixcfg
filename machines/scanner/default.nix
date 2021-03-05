{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./scanner.nix
  ];

  serial.enable = true;
  server.enable = true;

  backup = {
    enable = true;
    passphrase = secrets.backup.passphrase;
  };

  dns.host = {
    realm = "home";
    ipv4 = "172.23.200.134";
    ipv6 = "fd79:300d:6056:100::5";
  };
}
