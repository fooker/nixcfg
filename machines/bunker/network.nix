{ config, lib, pkgs, ... }:

{
  systemd.network = {
    enable = true;

    links = {
      "00-ext" = {
        matchConfig = {
          MACAddress = "52:54:10:e9:1b:37";
        };
        linkConfig = {
          Name = "ext";
        };
      };
    };

    networks = {
      "30-ext" = {
        name = "ext";
        address = [
          "37.120.161.15/22"
          "2a03:4000:6:30f2::/64"
        ];
        gateway = [ "37.120.160.1" ];
        dns = [ "1.0.0.1" "1.1.1.1" ];
      };
    };
  };
}
