{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  peering = {
    routerId = "1.2.3.5";

    domains = {
      "dn42" = {
        ipv4 = "172.23.200.127/32";
        ipv6 = "fd79:300d:6056:ffff::0/128";
      };
    };

    peers = {
      "zitadelle-north" = {
        netdev = "peer.x.znorth";

        local.port = null;
        local.privkey = secrets.peering.peers."zitadelle-north".privkey;

        remote.endpoint.host = "north.zitadelle.dev.open-desk.net";
        remote.endpoint.port = 23239;
        remote.pubkey = "2ZBSeB/L6FFuThB91uL0R1UCkUmJiIz7SAHXOGnxIng=";

        transfer = {
          ipv4.addr = "192.168.67.255";
          ipv4.peer = "192.168.67.254";

          ipv6.addr = "fe80::1";
          ipv6.peer = "fe80::2";
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

        remote.endpoint.host = "south.zitadelle.dev.open-desk.net";
        remote.endpoint.port = 23239;
        remote.pubkey = "2PoSn8qP90dQm/5Y9t93KWaRyWK+QP/ZgIZ6XFrF+gs=";

        transfer = {
          ipv4.addr = "192.168.67.253";
          ipv4.peer = "192.168.67.252";

          ipv6.addr = "fe80::1";
          ipv6.peer = "fe80::2";
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
