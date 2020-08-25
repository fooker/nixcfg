{ config, lib, pkgs, ... }:

{
  systemd.network = {
    enable = true;

    links = {
      "00-priv-raw" = {
        matchConfig = {
          MACAddress = "b8:ae:ed:7d:69:ab";
        };
        linkConfig = {
          Name = "priv-raw";
        };
      };
    };

    netdevs = {
      "30-priv" = {
        netdevConfig = {
          Name = "priv";
          Kind = "bridge";
        };
      };
    };

    networks = {
      "30-priv-raw" = {
        name = "priv-raw";
        bridge = [ "priv" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };
      "30-priv" = {
        name = "priv";
        address = [
          "172.23.200.131/25"
        ];
        gateway = [ "172.23.200.129" ];
        dns = [ "172.23.200.129" ];
        domains = [
          "home.open-desk.net"
          "priv.home.open-desk.net"
        ];
      };
    };
  };
}
