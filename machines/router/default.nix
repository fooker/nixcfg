{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./pppd.nix
    ./dns.nix
    ./ddclient.nix

    ./hass
  ];

  boot.type = "grub";
  serial.enable = true;
  server.enable = true;

  backhaul = {
    routerId = "1.2.3.4";

    domains = {
      "dn42" = {
        netdev = "priv";

        ipv4 = "172.23.200.129/25";
        ipv6 = "fd79:300d:6056:0100::0/56";
      };
    };

    peers = {
      "znorth" = {
        local.port = null;
        local.privkey = secrets.backhaul.peers."znorth".privkey;

        remote.host = "north.zitadelle.dev.open-desk.net";
        remote.port = 23230;
        remote.pubkey = "T9YqMKM8Jp+sFvwJN5Y2MV2aWQdIVJ7WhEsKMm9NUmI=";

        transport = {
          ipv4.addr = "192.168.67.7";
          ipv4.peer = "192.168.67.6";

          ipv6.addr = "fe80::2";
          ipv6.peer = "fe80::1";
        };

        domains = {
          "dn42" = {
            babel = {};
          };
        };
      };

      "zsouth" = {
        local.port = null;
        local.privkey = secrets.backhaul.peers."zsouth".privkey;

        remote.host = "south.zitadelle.dev.open-desk.net";
        remote.port = 23230;
        remote.pubkey = "nLwhi0ikvoZ6kze+m+CP5wP0hsP4NgigHMMMiGrXung=";

        transport = {
          ipv4.addr = "192.168.67.9";
          ipv4.peer = "192.168.67.8";

          ipv6.addr = "fe80::2";
          ipv6.peer = "fe80::1";
        };

        domains = {
          "dn42" = {
            babel = {};
          };
        };
      };
    };
  };
}
