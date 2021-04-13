{ config, lib, pkgs, ... }:

{
  systemd.network = {
    enable = true;

    links = {
      "00-ext" = {
        matchConfig = {
          MACAddress = "00:50:56:9c:d3:44";
        };
        linkConfig = {
          Name = "ext";
        };
      };
      "00-int" = {
        matchConfig = {
          MACAddress = "00:50:56:9c:68:c0";
        };
        linkConfig = {
          Name = "int";
        };
      };
      "00-hs" = {
        matchConfig = {
          MACAddress = "00:50:56:9c:a5:49";
        };
        linkConfig = {
          Name = "hs";
        };
      };
    };

    networks = {
      "30-ext" = {
        name = "ext";
        address = [
          "193.174.29.6/27"
          "2001:638:301:11a3::6/64"
        ];
        gateway = [ "193.174.29.1" ];
        dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
      };
      "30-int" = {
        name = "int";
        address = [
          config.peering.backhaul.dn42.ipv4
          config.peering.backhaul.dn42.ipv6
        ];
        gateway = [ "193.174.29.1" ];
      };
      "30-hs" = {
        name = "hs";
        address = [
          "192.168.31.93/24"
        ];
      };
    };
  };
}
