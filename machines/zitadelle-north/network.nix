{ config, lib, pkgs, ... }:

{
  systemd.network = {
    enable = true;

    links = {
      "00-ext" = {
        matchConfig = {
          MACAddress = "52:54:6e:09:06:f3";
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
          "37.120.172.185/22"
          "2a03:4000:6:701e::/64"
        ];
        gateway = [ "37.120.172.1" ];
        dns = [ "1.0.0.1" "1.1.1.1" ];
      };
    };
  };
}
