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

    ./hass.nix
  ];

  environment.systemPackages = with pkgs; [
    wget vim
    nmap tcpdump
    ldns
  ];

  boot.type = "grub";
  serial.enable = true;
  server.enable = true;
}
