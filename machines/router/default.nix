{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./pppd.nix
    ./dns.nix
    ./ddclient.nix
    ./backhaul.nix
    ./hass.nix
  ];

  serial.enable = true;
  server.enable = true;

  backup = {
    enable = true;
    passphrase = secrets.backup.passphrase;
  };
}
