{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  peering = {
    routerId = "1.2.3.4";

    domains = {
      "dn42" = {
        netdev = "priv";

        ipv4 = "172.23.200.129/25";
        ipv6 = "fd79:300d:6056:100::0/64";
      };
    };

    peers = {
      "zitadelle-north" = {
        netdev = "peer.x.znorth";

        local.port = null;
        local.privkey = secrets.peering.peers."zitadelle-north".privkey;

        remote.host = "north.zitadelle.dev.open-desk.net";
        remote.port = 23230;
        remote.pubkey = "T9YqMKM8Jp+sFvwJN5Y2MV2aWQdIVJ7WhEsKMm9NUmI=";

        transfer = {
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

      "zitadelle-south" = {
        netdev = "peer.x.zsouth";

        local.port = null;
        local.privkey = secrets.peering.peers."zitadelle-south".privkey;

        remote.host = "south.zitadelle.dev.open-desk.net";
        remote.port = 23230;
        remote.pubkey = "nLwhi0ikvoZ6kze+m+CP5wP0hsP4NgigHMMMiGrXung=";

        transfer = {
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
