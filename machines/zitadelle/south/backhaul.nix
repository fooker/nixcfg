{ config, lib, pkgs, name, ... }:

let
  secrets = import ./secrets.nix;
in {
  backhaul = {
    routerId = "37.120.172.177";

    domains = {
      "dn42" = {
        ipv4 = "172.23.200.2/32";
        ipv6 = "fd79:300d:6056::2/128";
      };

      "hive" = {
        ipv4 = "${config.hive.self.address.ipv4}/32";
        ipv6 = "${config.hive.self.address.ipv6}/128";
      };
    };

    peers = {
      "zitadelle-north" = {
        netdev = "peer.x.znorth";

        local.port = 23231;
        local.privkey = secrets.backhaul.peers."zitadelle-north".privkey;

        remote.host = "north.zitadelle.dev.open-desk.net";
        remote.port = 23231;
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
            bgp = {};
          };
          "hive" = {
            ospf = {};
          };
        };
      };

      "bunker" = {
        netdev = "peer.x.bunker";

        local.port = 23233;
        local.privkey = secrets.backhaul.peers."bunker".privkey;

        remote.host = "bunker.dev.open-desk.net";
        remote.port = 23233;
        remote.pubkey = "2z55B78CGG84aHgZsHZHY43iBas6Lpd9vLTZcT3PzCg=";

        transfer = {
          ipv4.addr = "192.168.67.2";
          ipv4.peer = "192.168.67.3";

          ipv6.addr = "fe80::1";
          ipv6.peer = "fe80::2";
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

      "router" = {
        netdev = "peer.x.router";

        local.port = 23230;
        local.privkey = secrets.backhaul.peers."router".privkey;

        remote.pubkey = "ZWz+RCg53WjVUn3kWqK8EB26atulPGQmvHGlVEZpRQA=";

        transfer = {
          ipv4.addr = "192.168.67.8";
          ipv4.peer = "192.168.67.9";

          ipv6.addr = "fe80::1";
          ipv6.peer = "fe80::2";
        };

        domains = {
          "dn42" = {
            babel = {};
          };
        };
      };

      "mobile" = {
        netdev = "peer.x.mobile";

        local.port = 23239;
        local.privkey = secrets.backhaul.peers."mobile".privkey;

        remote.pubkey = "iocF4MZa3Q44wxq8ollp4/3Ni+OX0oSLqz+xfAUmly8=";

        transfer = {
          ipv4.addr = "192.168.67.252";
          ipv4.peer = "192.168.67.253";

          ipv6.addr = "fe80::2";
          ipv6.peer = "fe80::1";
        };

        domains = {
          "dn42" = {
            babel = {};
          };
        };
      };

      "major1" = {
        netdev = "peer.major1";

        local.port = 23423;
        local.privkey = secrets.backhaul.peers."major1".privkey;

        remote.host = "193.239.104.101";
        remote.port = 42102;
        remote.pubkey = "2TUO7Aml21ppyciumxBukZyjO+YkHyFP087mu4MbRDY=";

        transfer = {
          ipv4.addr = "169.254.42.3";
          ipv4.peer = "169.254.42.2";

          ipv6.addr = "fe80::2";
          ipv6.peer = "fe80::1";
        };

        domains = {
          "dn42" = {
            bgp = {
              as = 4242422600;
            };
          };
        };
      };

      "major2" = {
        netdev = "peer.major2";

        local.port = 23424;
        local.privkey = secrets.backhaul.peers."major2".privkey;

        remote.host = "193.239.104.103";
        remote.port = 42102;
        remote.pubkey = "ebhr1DqDTfitH3XlZCT7j6DnEXP1+Ax3krei9CzNICo=";

        transfer = {
          ipv4.addr = "169.254.42.7";
          ipv4.peer = "169.254.42.6";

          ipv6.addr = "fe80::2";
          ipv6.peer = "fe80::1";
        };

        domains = {
          "dn42" = {
            bgp = {
              as = 4242422600;
            };
          };
        };
      };

      "cccda" = {
        netdev = "peer.cccda";

        local.port = 23420;
        local.privkey = secrets.backhaul.peers."cccda".privkey;

        remote.host = "core1.darmstadt.ccc.de";
        remote.port = 43009;
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
        local.privkey = secrets.backhaul.peers."ffffm".privkey;

        remote.host = "icvpn2.aixit.off.de.ffffm.net";
        remote.port = 40107;
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
        local.privkey = secrets.backhaul.peers."maglab".privkey;

        remote.host = "lintillas.maglab.space";
        remote.port = 42006;
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
        local.privkey = secrets.backhaul.peers."clerie".privkey;

        remote.host = "dn42-il-gw1.net.clerie.de";
        remote.port = 51272;
        remote.pubkey = "F1qXLmLwmg27+cGTyKBsp6Fh+K6H3GWthQYvafuznnQ=";

        transfer = {
          ipv4.addr = "169.254.42.9";
          ipv4.peer = "169.254.42.8";

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
        local.privkey = secrets.backhaul.peers."maraun".privkey;

        remote.host = "dn42-de.maraun.de";
        remote.port = 21271;
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
    };
  };
}
