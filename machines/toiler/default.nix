{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./jellyfin.nix
    ./user.nix
  ];

  server.enable = true;

  backup = {
    enable = true;
    passphrase = secrets.backup.passphrase;
  };

  
}
