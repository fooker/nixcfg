{ config, lib, pkgs, name, ... }:

let
  secrets = import ./secrets.nix;
in {
  peering = {
    routerId = "37.120.172.185";

    domains = {
      "dn42" = {
        ipv4 = "172.23.200.1/32";
        ipv6 = "fd79:300d:6056::1/128";
      };

      "hive" = {
        ipv4 = "${config.hive.self.address.ipv4}/32";
        ipv6 = "${config.hive.self.address.ipv6}/128";
      };
    };

    peers = {
      "zitadelle-south" = {
        netdev = "peer.x.zsouth";

        local.port = 23231;
        local.privkey = secrets.peering.peers."zitadelle-south".privkey;

        remote.endpoint.host = "south.zitadelle.dev.open-desk.net";
        remote.endpoint.port = 23231;
        remote.pubkey = "pUi16/k8HksFrlVVR15RH7vc1xwUu5n+DhYvn6u5OGo=";

        transfer = {
          ipv4.addr = "192.168.67.0";
          ipv4.peer = "192.168.67.1";

          ipv6.addr = "fe80::1";
          ipv6.peer = "fe80::2";
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

        local.port = 23232;
        local.privkey = secrets.peering.peers."bunker".privkey;

        remote.endpoint.host = "bunker.dev.open-desk.net";
        remote.endpoint.port = 23232;
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
        netdev = "peer.x.router";

        local.port = 23230;
        local.privkey = secrets.peering.peers."router".privkey;

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

        local.port = 23239;
        local.privkey = secrets.peering.peers."mobile".privkey;

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

      # "major1" = {
      #   netdev = "peer.major1";

      #   local.port = 23423;
      #   local.privkey = secrets.peering.peers."major1".privkey;

      #   remote.endpoint.host = "193.239.104.101";
      #   remote.endpoint.port = 42101;
      #   remote.pubkey = "RQ1nOR6CeUHuLOg8QoZHGPWVN8yY/HYhHC3KKfzZ5H4=";

      #   transfer = {
      #     ipv4.addr = "169.254.42.1";
      #     ipv4.peer = "169.254.42.0";

      #     ipv6.addr = "fe80::2";
      #     ipv6.peer = "fe80::1";
      #   };

      #   domains = {
      #     "dn42" = {
      #       bgp = {
      #         as = 4242422600;
      #       };
      #     };
      #   };
      # };

      # "major2" = {
      #   netdev = "peer.major2";

      #   local.port = 23424;
      #   local.privkey = secrets.peering.peers."major2".privkey;

      #   remote.endpoint.host = "193.239.104.103";
      #   remote.endpoint.port = 42101;
      #   remote.pubkey = "9otCYTT2Eg+W5s3jEIXyVnclGAY/fOpcf21IOMH/VWI=";

      #   transfer = {
      #     ipv4.addr = "169.254.42.5";
      #     ipv4.peer = "169.254.42.4";

      #     ipv6.addr = "fe80::2";
      #     ipv6.peer = "fe80::1";
      #   };

      #   domains = {
      #     "dn42" = {
      #       bgp = {
      #         as = 4242422600;
      #       };
      #     };
      #   };
      # };

      "cccda" = {
        netdev = "peer.cccda";

        local.port = 23420;
        local.privkey = secrets.peering.peers."cccda".privkey;

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
        local.privkey = secrets.peering.peers."ffffm".privkey;

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
        local.privkey = secrets.peering.peers."maglab".privkey;

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
        local.privkey = secrets.peering.peers."clerie".privkey;

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
        local.privkey = secrets.peering.peers."maraun".privkey;

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
    };
  };
}
