{ config, lib, pkgs, ... }:

{
  networking.wireless.iwd.enable = true;

  systemd.network = {
    enable = true;

    links = {
      "00-en" = {
        matchConfig = {
          MACAddress = "00:2b:67:5f:55:13";
          Type = "ether";
        };
        linkConfig = {
          Name = "en-raw";
        };
      };

      "00-wl" = {
        matchConfig = {
          MACAddress = "cc:f9:e4:f4:90:11";
          Type = "wlan";
        };
        linkConfig = {
          Name = "wl";
        };
      };
    };

    netdevs = {
      "30-en" = {
        netdevConfig = {
          Name = "en";
          Kind = "bridge";
        };
      };
    };

    networks = {
      "30-en-raw" = {
        name = "en-raw";
        bridge = [ "en" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };
      "30-en" = {
        name = "en";
        DHCP = "yes";
      };
      "30-wl" = {
        name = "wl";
        DHCP = "yes";
      };
    };
  };
}
