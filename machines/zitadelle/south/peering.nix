{
  peering = {
    routerId = "37.120.172.177";

    backhaul = {
      enable = true;

      deviceId = 2;
      slug = "zsouth";

      hub = true;

      dn42.ipv4 = "172.23.200.2/32";
      dn42.ipv6 = "fd79:300d:6056::2/128";
    };

    peers = {
      "backhaul.znorth".domains = {
        "dn42" = {
          bgp = {
            as = null;
          };
        };
      };

      "cccda" = {
        netdev = "peer.cccda";

        local.port = 23420;

        remote.endpoint.host = "core1.darmstadt.ccc.de";
        remote.endpoint.port = 43009;
        remote.pubkey = "B9v1EHhXAoCNbF8WZQe3Tdrm2GhvHZi6b59a/xlpESA=";

        transfer = {
          ipv4.addr = "172.20.253.29";
          ipv4.peer = "172.20.253.28";

          ipv6.addr = "fd5a:ad49:84cc::253:28:2";
          ipv6.peer = "fd5a:ad49:84cc::253:28:1";
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

        remote.endpoint.host = "icvpn2.aixit.off.de.ffffm.net";
        remote.endpoint.port = 40107;
        remote.pubkey = "e8z+pYfwLdj3yEThh7etkOnkwRu/4HOmKNoT0GAVZjg=";

        transfer = {
          ipv4.addr = "192.168.237.3";
          ipv4.peer = "192.168.237.2";

          ipv6.addr = "fd74:f175:7a21:4f22::3";
          ipv6.peer = "fd74:f175:7a21:4f22::2";
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

        remote.endpoint.host = "lintillas.maglab.space";
        remote.endpoint.port = 42006;
        remote.pubkey = "wKN9BrkkKv884EBifkMMlwy96PADSOvaM9g5kM+Ub10=";

        transfer = {
          ipv4.addr = "192.168.234.7";
          ipv4.peer = "192.168.234.6";

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

        remote.endpoint.host = "dn42-il-gw1.net.clerie.de";
        remote.endpoint.port = 51272;
        remote.pubkey = "F1qXLmLwmg27+cGTyKBsp6Fh+K6H3GWthQYvafuznnQ=";

        transfer = {
          ipv4 = null;

          ipv6.addr = "fe80::1:2";
          ipv6.peer = "fe80::1:1";
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

        remote.endpoint.host = "dn42-de.maraun.de";
        remote.endpoint.port = 21271;
        remote.pubkey = "uS1AYe7zTGAP48XeNn0vppNjg7q0hawyh8Y0bvvAWhk=";

        transfer = {
          ipv4.addr = "192.168.234.7";
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

        remote.endpoint.host = "p2p-router.de";
        remote.endpoint.port = 51271;
        remote.pubkey = "Lcx03wDehPX72ql/r8wmReZK6jHP1VpX5TADgRp0nF0=";

        transfer = {
          ipv4.addr = "192.168.234.11";
          ipv4.peer = "192.168.234.12";

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

      "indigo" = {
        netdev = "peer.indigo";

        local.port = 23428;

        remote.endpoint.host = "booty.labmonkeys.space";
        remote.endpoint.port = 51820;
        remote.pubkey = "G+h5ho6X3C76HxGQw9ZoX3dpRCOspPe9F1vo49ullCg=";

        transfer = {
          ipv4.addr = "192.168.234.17";
          ipv4.peer = "192.168.234.16";

          ipv6.addr = "fe80::1";
          ipv6.peer = "fe80::2";
        };

        domains = {
          "dn42" = {
            bgp = {
              as = 4242422423;
            };
          };
        };
      };
    };
  };
}
