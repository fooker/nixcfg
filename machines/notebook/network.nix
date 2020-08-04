{ config, lib, pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;

    ethernet.macAddress = "random";
    wifi.macAddress = "random";
    wifi.backend = "iwd";
    wifi.powersave = true;

    #dns = "systemd-resolved";

    unmanaged = [ "interface-name:docker0;veth*" ];
  };

  # systemd.network = {
  #   enable = true;

  #   links = {
  #     "00-en" = {
  #       matchConfig = {
  #         MACAddress = "00:2b:67:5f:55:13";
  #       };
  #       linkConfig = {
  #         Name = "en";
  #       };
  #     };

  #     "00-wl" = {
  #       matchConfig = {
  #         MACAddress = "cc:f9:e4:f4:90:11";
  #       };
  #       linkConfig = {
  #         Name = "wl";
  #       };
  #     };
  #   };

  #   networks = {
  #     "30-en" = {
  #       name = "en";
  #       address = [
  #         "172.23.200.242/25"
  #       ];
  #       gateway = [ "172.23.200.129" ];
  #       dns = [ "172.23.200.129" ];
  #       # domains = [
  #       #   "home.open-desk.net"
  #       #   "priv.home.open-desk.net"
  #       # ];
  #     };
  #   };
  # };
}
