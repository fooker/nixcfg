{
  prefixes = {
    # Private Network @ Home
    "172.23.200.128/25" = {
      site = "home";

      gateway = "172.23.200.129";
      dns = [ "172.23.200.129" ];

      addresses = {
        "172.23.200.129" = {
          device = "router";
          interface = "priv";
        };
        "172.23.200.130" = {
          device = "nas";
          interface = "priv";
        };
        "172.23.200.131" = {
          device = "toiler";
          interface = "priv";
        };
        "172.23.200.132" = {
          device = "prusa";
          interface = "priv";
        };
        "172.23.200.133" = {
          device = "amp";
          interface = "priv";
        };
        "172.23.200.134" = {
          device = "scanner";
          interface = "priv";
        };
        "172.23.200.135" = {
          device = "photonic";
          interface = "priv";
        };

        "172.23.200.160" = {
          device = "printer";
          interface = "priv";
        };
      };

      # reservations = {
      #   "dhcp" = {
      #     range = [ "172.23.200.160" "172.23.200.254" ];
      #     description = "DHCP clients";
      #   };
      # };
    };

    # Private Network @ Home
    "fd79:300d:6056:100::/64" = {
      site = "home";

      gateway = "fd79:300d:6056:100::0";
      dns = [ "fd79:300d:6056:100::0" ];

      addresses = {
        "fd79:300d:6056:100::0" = {
          device = "router";
          interface = "priv";
        };
        "fd79:300d:6056:100::1" = {
          device = "nas";
          interface = "priv";
        };
        "fd79:300d:6056:100::2" = {
          device = "toiler";
          interface = "priv";
        };
        "fd79:300d:6056:100::3" = {
          device = "prusa";
          interface = "priv";
        };
        "fd79:300d:6056:100::4" = {
          device = "amp";
          interface = "priv";
        };
        "fd79:300d:6056:100::5" = {
          device = "scanner";
          interface = "priv";
        };
        "fd79:300d:6056:100::6" = {
          device = "photonic";
          interface = "priv";
        };

        "fd79:300d:6056:100::1F" = {
          device = "printer";
          interface = "priv";
        };
      };
    };

    # Management Network @ Home
    "192.168.254.0/24" = {
      site = "home";

      gateway = "192.168.254.1";
      dns = [ "192.168.254.1" ];

      addresses = {
        "192.168.254.1" = {
          device = "router";
          interface = "mngt";
        };
        "192.168.254.2" = {
          device = "modem";
          interface = "mngt";
        };
        "192.168.254.3" = {
          device = "br1";
          interface = "mngt";
        };
        "192.168.254.4" = {
          device = "br2";
          interface = "mngt";
        };
        "192.168.254.5" = {
          device = "br3";
          interface = "mngt";
        };
        "192.168.254.140" = {
          device = "ap-upstairs";
          interface = "mngt";
        };
        "192.168.254.157" = {
          device = "ap-downstairs";
          interface = "mngt";
        };
      };
    };

    # Guest Network @ Home
    "203.0.113.0/24" = {
      site = "home";

      gateway = "203.0.113.1";
      dns = [ "203.0.113.1" ];

      addresses = {
        "203.0.113.1" = {
          device = "router";
          interface = "guest";
        };
      };
    };

    # IoT Network @ Home
    "192.168.0.0/24" = {
      site = "home";

      gateway = "192.168.0.1";
      dns = [ "192.168.0.1" ];

      addresses = {
        "192.168.0.1" = {
          device = "router";
          interface = "iot";
        };
      };
    };

    # Private Network @ University
    "172.23.200.32/28" = {
      site = "hs";

      gateway = "172.23.200.33";

      addresses = {
        "172.23.200.33" = {
          device = "brueckenkopf";
          interface = "int";
        };

        "172.23.200.34" = {
          device = "paradeplatz";
          interface = "int";
        };

        "172.23.200.35" = {
          device = "builder";
          interface = "int";
        };

        "172.23.200.36" = {
          device = "raketensilo";
          interface = "int";
        };
      };
    };

    # Private Network @ University
    "fd79:300d:6056:1::/64" = {
      site = "hs";

      gateway = "fd79:300d:6056:1::";

      addresses = {
        "fd79:300d:6056:1::0" = {
          device = "brueckenkopf";
          interface = "int";
        };

        "fd79:300d:6056:1::1" = {
          device = "paradeplatz";
          interface = "int";
        };

        "fd79:300d:6056:1::2" = {
          device = "builder";
          interface = "int";
        };

        "fd79:300d:6056:1::3" = {
          device = "raketensilo";
          interface = "int";
        };
      };
    };

    # Lab Network @ University
    "192.168.31.0/24" = {
      site = "hs";

      addresses = {
        "192.168.31.28" = {
          device = "paradeplatz";
          interface = "lab";
        };

        "192.168.31.93" = {
          device = "brueckenkopf";
          interface = "lab";
        };

        "192.168.31.241" = {
          device = "raketensilo";
          interface = "lab";
        };
      };
    };
  };
}
