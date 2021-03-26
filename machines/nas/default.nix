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

  # Used to upload scanned documents
  users.users."scanner" = {
    home = "/mnt/files/scans";
    createHome = true;

    shell = "/bin/sh";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyp+ijJxUeY23fr/J+CzBTQvWtBwX6FookGYA24IwI3 scanner@sacnner"
    ];
  };

  backup.paths = [
    config.users.users."scanner".home
  ];
}
