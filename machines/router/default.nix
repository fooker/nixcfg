{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./network.nix
    ./pppd.nix
    ./dns.nix
    ./ddclient.nix
    ./backhaul.nix

    ./hass
  ];

  boot.type = "grub";
  serial.enable = true;
  server.enable = true;
}
