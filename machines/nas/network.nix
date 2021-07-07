{ lib, ... }:

with lib;

let
  devices = imap1
    (i: mac: rec {
      iface = "priv-${ toString i }";

      name = "00-${iface}";

      link = {
        matchConfig = {
          MACAddress = mac;
        };
        linkConfig = {
          Name = iface;
        };
      };

      network = {
        name = iface;
        bond = [ "priv" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };
    })
    [
      "24:5e:be:35:8b:d5"
      "24:5e:be:35:8b:d6"
      "24:5e:be:35:8b:d7"
      "24:5e:be:35:8b:d8"
    ];
in
{
  systemd.network = {
    enable = true;

    links = listToAttrs
      (map (device: nameValuePair device.name device.link) devices);

    netdevs = {
      "30-priv" = {
        netdevConfig = {
          Name = "priv";
          Kind = "bond";
        };
        bondConfig = {
          Mode = "802.3ad";
          TransmitHashPolicy = "layer3+4";
          LACPTransmitRate = "fast";
        };
      };
    };

    networks = (listToAttrs
      (map (device: nameValuePair device.name device.network) devices)
    ) // {
      "30-priv" = {
        name = "priv";
        address = [
          "172.23.200.130/25"
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
