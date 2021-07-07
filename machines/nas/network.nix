{ config, lib, pkgs, ... }:

with lib;
let
  devices = [
    "24:5e:be:35:8b:d5"
    "24:5e:be:35:8b:d6"
    "24:5e:be:35:8b:d7"
    "24:5e:be:35:8b:d8"
  ];
in
{
  systemd.network = {
    enable = true;

    links = (listToAttrs (imap1
      (i: mac: (
        let
          name = "priv-${ toString i }";
        in
        (nameValuePair "00-${ name }" {
          matchConfig = {
            MACAddress = mac;
          };
          linkConfig = {
            Name = name;
          };
        })
      ))
      devices));

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

    networks = (listToAttrs (imap1
      (i: mac: (
        let
          name = "priv-${ toString i }";
        in
        (nameValuePair "00-${ name }" {
          name = name;
          bond = [ "priv" ];
          networkConfig = {
            LinkLocalAddressing = "no";
          };
        })
      ))
      devices)
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
