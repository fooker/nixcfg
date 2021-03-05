{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./backhaul.nix
    ./dns/default.nix
    ./syncthing.nix
  ];

  server.enable = true;

  hive = {
    enable = true;
  };

  backup = {
    enable = true;
    passphrase = secrets.backup.passphrase;
  };
}
