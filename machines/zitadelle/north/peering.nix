let
  secrets = import ./secrets.nix;
in
{
  peering = {
    routerId = "37.120.172.185";

    backhaul = {
      enable = true;

      deviceId = 1;
      slug = "znorth";

      hub = true;

      dn42.ipv4 = "172.23.200.1/32";
      dn42.ipv6 = "fd79:300d:6056::1/128";
    };

    peers = {
      "backhaul.zsouth".local.privkey = secrets.peering.privkeys."backhaul.zsouth";
      "backhaul.bunker".local.privkey = secrets.peering.privkeys."backhaul.bunker";
      "backhaul.router".local.privkey = secrets.peering.privkeys."backhaul.router";
      "backhaul.notebook".local.privkey = secrets.peering.privkeys."backhaul.notebook";
      "backhaul.brkopf".local.privkey = secrets.peering.privkeys."backhaul.brkopf";

      "backhaul.zsouth".domains = {
        "dn42" = {
          bgp = {
            as = null;
          };
        };
      };

      "cccda" = {
        netdev = "peer.cccda";

        local.port = 23420;
        local.privkey = secrets.peering.privkeys."cccda";

        remote.endpoint.host = "core1.darmstadt.ccc.de";
        remote.endpoint.port = 43007;
        remote.pubkey = "B9v1EHhXAoCNbF8WZQe3Tdrm2GhvHZi6b59a/xlpESA=";

        transfer = {
          ipv4.addr = "172.20.253.25";
          ipv4.peer = "172.20.253.24";

          ipv6.addr = "fd5a:ad49:84cc::253:24:2";
          ipv6.peer = "fd5a:ad49:84cc::253:24:1";
        };

        domains = {
          "dn42" = {
            bgp = {
              as = 4242420101;
            };
          };
        };
      };

      "ffffm" = {
        netdev = "peer.ffffm";

        local.port = 23422;
        local.privkey = secrets.peering.privkeys."ffffm";

        remote.endpoint.host = "icvpn2.aixit.off.de.ffffm.net";
        remote.endpoint.port = 40106;
        remote.pubkey = "W7M6vBlS7yCaV6q1Z951ebAnb1POzFOZth2Ryr8qZxw=";

        transfer = {
          ipv4.addr = "192.168.237.1";
          ipv4.peer = "192.168.237.0";

          ipv6.addr = "fd74:f175:7a21:4f22::1";
          ipv6.peer = "fd74:f175:7a21:4f22::0";
        };

        domains = {
          "dn42" = {
            bgp = {
              as = 65026;
            };
          };
        };
      };

      "maglab" = {
        netdev = "peer.maglab";

        local.port = 23421;
        local.privkey = secrets.peering.privkeys."maglab";

        remote.endpoint.host = "lintillas.maglab.space";
        remote.endpoint.port = 42005;
        remote.pubkey = "mTOnizd4uUjUqoMP1WiJdR/LeqyeIc3d+3dJnO5Z5yE=";

        transfer = {
          ipv4.addr = "192.168.234.5";
          ipv4.peer = "192.168.234.4";

          ipv6.addr = "fe80:42::2";
          ipv6.peer = "fe80:42::1";
        };

        domains = {
          "dn42" = {
            bgp = {
              as = 4242422800;
            };
          };
        };
      };

      "clerie" = {
        netdev = "peer.clerie";

        local.port = 23425;
        local.privkey = secrets.peering.privkeys."clerie";

        remote.endpoint.host = "dn42-il-gw1.net.clerie.de";
        remote.endpoint.port = 51271;
        remote.pubkey = "QAhnJupvnLWsbIilHsd+cPZqZw8DDC1f8r+JB8Yz+GA=";

        transfer = {
          ipv4 = null;

          ipv6.addr = "fe80::2";
          ipv6.peer = "fe80::1";
        };

        domains = {
          "dn42" = {
            bgp = {
              as = 4242422574;
            };
          };
        };
      };

      "maraun" = {
        netdev = "peer.maraun";

        local.port = 23426;
        local.privkey = secrets.peering.privkeys."maraun";

        remote.endpoint.host = "dn42-de.maraun.de";
        remote.endpoint.port = 21271;
        remote.pubkey = "uS1AYe7zTGAP48XeNn0vppNjg7q0hawyh8Y0bvvAWhk=";

        transfer = {
          ipv4.addr = "192.168.234.9";
          ipv4.peer = "172.20.12.196";

          ipv6.addr = "fe80::1";
          ipv6.peer = "fe80::42:4242:2225";
        };

        domains = {
          "dn42" = {
            bgp = {
              as = 4242422225;
            };
          };
        };
      };

      "mk16" = {
        netdev = "peer.mk16";

        local.port = 23427;
        local.privkey = secrets.peering.privkeys."mk16";

        remote.endpoint.host = "p2p-router.de";
        remote.endpoint.port = 51271;
        remote.pubkey = "q9gy/VFwEacdMIReCih0HVkkVeo/eQ5eUDPLo9ryVjE=";

        transfer = {
          ipv4.addr = "192.168.234.13";
          ipv4.peer = "192.168.234.14";

          ipv6.addr = "fe80::1";
          ipv6.peer = "fe80::2";
        };

        domains = {
          "dn42" = {
            bgp = {
              as = 4242422923;
            };
          };
        };
      };
    };
  };
}
