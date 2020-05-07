{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./vault.nix
    ./shares.nix
    ./deluge.nix
    ./syncthing.nix
    ./backup.nix
    ./mmv.nix
  ];

  server.enable = true;
  serial.enable = true;

  backup = {
    enable = true;
    passphrase = secrets.backup.passphrase;
  };

  environment.systemPackages = with pkgs; [
    unrar
    unzip
  ];
}
