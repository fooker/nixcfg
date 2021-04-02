{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;

  mmv = pkgs.callPackage ../../packages/mmv.nix {};
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./vault.nix
    ./shares.nix
    ./deluge.nix
    ./syncthing.nix
    ./backup.nix
    ./scanner.nix
  ];

  server.enable = true;
  serial.enable = true;

  backup.passphrase = secrets.backup.passphrase;

  dns.host = {
    realm = "home";
    ipv4 = "172.23.200.130";
    ipv6 = "fd79:300d:6056:100::1";
  };

  environment.systemPackages = with pkgs; [
    mmv

    unrar
    unzip
  ];
}
