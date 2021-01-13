{ config, lib, pkgs, name, ... }:

let
  secrets = import ./secrets.nix;
in {
  backhaul = {
    routerId = "37.120.161.15";

    domains = {
      "dn42" = {
        ipv4 = "172.23.200.3/32";
        ipv6 = "fd79:300d:6056::3/128";
      };

      "hive" = {
        ipv4 = "${config.hive.self.address.ipv4}/32";
        ipv6 = "${config.hive.self.address.ipv6}/128";
      };
    };

    peers = {
      "zitadelle-north" = {
        netdev = "peer.x.znorth";

        local.port = 23232;
        local.privkey = secrets.backhaul.peers."zitadelle-north".privkey;

        remote.host = "north.zitadelle.dev.open-desk.net";
        remote.port = 23232;
        remote.pubkey = "RMqnHRdIdLU8sfeh/8Rb2aenclhYjyFwlCGcKkL28gw=";

        transfer = {
          ipv4.addr = "192.168.67.5";
          ipv4.peer = "192.168.67.4";

          ipv6.addr = "fe80::2";
          ipv6.peer = "fe80::1";
        };

        domains = {
          "dn42" = {
            babel = {};
          };
          "hive" = {
            ospf = {};
          };
        };
      };

      "zitadelle-south" = {
        netdev = "peer.x.zsouth";

        local.port = 23233;
        local.privkey = secrets.backhaul.peers."zitadelle-south".privkey;

        remote.host = "south.zitadelle.dev.open-desk.net";
        remote.port = 23233;
        remote.pubkey = "8SFQts6atZ4GKLuEFKYuwqjKFqkx1UzVCk74iB9htG8=";

        transfer = {
          ipv4.addr = "192.168.67.3";
          ipv4.peer = "192.168.67.2";

          ipv6.addr = "fe80::2";
          ipv6.peer = "fe80::1";
        };

        domains = {
          "dn42" = {
            babel = {};
          };
          "hive" = {
            ospf = {};
          };
        };
      };
    };
  };
}
