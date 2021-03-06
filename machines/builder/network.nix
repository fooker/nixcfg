{ config, lib, pkgs, ... }:

{
  systemd.network = {
    enable = true;

    links = {
      "00-ext" = {
        matchConfig = {
          MACAddress = "52:54:00:57:ff:27";
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
          "192.168.42.2/24"
        ];
        gateway = [ "192.168.42.1" ];
        dns = [ "1.0.0.1" "1.1.1.1" ];
      };
    };
  };
}
