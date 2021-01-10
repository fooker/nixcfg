{ config, lib, pkgs, ... }:

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
        ipv4 = "192.168.33.3/32";
        ipv6 = "fd4c:8f0:aff2::3/128";
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

      "bunker" = {
        netdev = "peer.x.bunker";

        local.port = 23232;
        local.privkey = secrets.backhaul.peers."bunker".privkey;

        remote.host = "bunker.dev.open-desk.net";
        remote.port = 23232;
        remote.pubkey = "a/BhSnxlKqe3gVAtKRXeKhuAtIL5csqzd1QYyJ/wbUo=";

        transfer = {
          ipv4.addr = "192.168.67.4";
          ipv4.peer = "192.168.67.5";

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
        netdev = "peer.x.bunker";

        local.port = 23230;
        local.privkey = secrets.backhaul.peers."router".privkey;

        remote.pubkey = "vjjnr+4LzQfbgSon0/ADFEc3+kppB9hoD3vXnXf77Cs=";

        transfer = {
          ipv4.addr = "192.168.67.6";
          ipv4.peer = "192.168.67.7";

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

        local.port = 23230;
        local.privkey = secrets.backhaul.peers."mobile".privkey;

        remote.pubkey = "dj9ooKzq0dFJIxnt6BKJ5Qz0akg0E44BXVbrQL0GHCs=";

        transfer = {
          ipv4.addr = "192.168.67.254";
          ipv4.peer = "192.168.67.255";

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
        remote.port = 42101;
        remote.pubkey = "RQ1nOR6CeUHuLOg8QoZHGPWVN8yY/HYhHC3KKfzZ5H4=";

        transfer = {
          ipv4.addr = "169.254.42.1";
          ipv4.peer = "169.254.42.0";

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
        remote.port = 42101;
        remote.pubkey = "9otCYTT2Eg+W5s3jEIXyVnclGAY/fOpcf21IOMH/VWI=";

        transfer = {
          ipv4.addr = "169.254.42.5";
          ipv4.peer = "169.254.42.4";

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
        remote.port = 43007;
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
        local.privkey = secrets.backhaul.peers."ffffm".privkey;

        remote.host = "icvpn2.aixit.off.de.ffffm.net";
        remote.port = 40106;
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
        local.privkey = secrets.backhaul.peers."maglab".privkey;

        remote.host = "lintillas.maglab.space";
        remote.port = 42005;
        remote.pubkey = "mTOnizd4uUjUqoMP1WiJdR/LeqyeIc3d+3dJnO5Z5yE=";

        transfer = {
          ipv4.addr = "192.168.237.5";
          ipv4.peer = "192.168.237.4";

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
        remote.port = 51271;
        remote.pubkey = "QAhnJupvnLWsbIilHsd+cPZqZw8DDC1f8r+JB8Yz+GA=";

        transfer = {
          ipv4.addr = "169.254.42.9";
          ipv4.peer = "169.254.42.8";

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
        local.privkey = secrets.backhaul.peers."maraun".privkey;

        remote.host = "dn42-de.maraun.de";
        remote.port = 21271;
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
    };
  };
}
