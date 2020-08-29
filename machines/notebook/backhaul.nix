{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  backhaul = {
    routerId = "1.2.3.5";

    domains = {
      "dn42" = {
        ipv4 = "172.23.200.127/32";
        ipv6 = "fd79:300d:6056:ffff::0/128";
      };
    };

    peers = {
      "znorth" = {
        local.port = null;
        local.privkey = secrets.backhaul.peers."znorth".privkey;

        remote.host = "north.zitadelle.dev.open-desk.net";
        remote.port = 23239;
        remote.pubkey = "2ZBSeB/L6FFuThB91uL0R1UCkUmJiIz7SAHXOGnxIng=";

        transport = {
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

      "zsouth" = {
        local.port = null;
        local.privkey = secrets.backhaul.peers."zsouth".privkey;

        remote.host = "south.zitadelle.dev.open-desk.net";
        remote.port = 23239;
        remote.pubkey = "2PoSn8qP90dQm/5Y9t93KWaRyWK+QP/ZgIZ6XFrF+gs=";

        transport = {
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