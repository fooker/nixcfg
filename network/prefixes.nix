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
        "172.23.200.133" = {
          device = "amp";
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
        "172.23.200.161" = {
          device = "prusa";
          interface = "priv";
        };
      };

      reservations = {
        "dhcp" = {
          range = [ "172.23.200.160" "172.23.200.254" ];
          description = "DHCP clients";
        };
      };
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
        "fd79:300d:6056:100::4" = {
          device = "amp";
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
        "192.168.254.8" = {
          device = "phone";
          interface = "mngt";
        };
        "192.168.254.16" = {
          device = "ap-downstairs";
          interface = "mngt";
        };
        "192.168.254.17" = {
          device = "ap-upstairs";
          interface = "mngt";
        };
      };

      reservations = {
        "dhcp" = {
          range = [ "192.168.254.128" "192.168.254.254" ];
          description = "DHCP clients";
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

      reservations = {
        "dhcp" = {
          range = [ "203.0.113.16" "203.0.113.254" ];
          description = "DHCP clients";
        };
      };
    };

    # IoT Network @ Home
    "192.168.0.0/24" = {
      site = "home";

      dns = [ "192.168.0.1" ];

      addresses = {
        "192.168.0.1" = {
          device = "router";
          interface = "iot";
        };
        "192.168.0.2" = {
          device = "toiler";
          interface = "iot";
        };
      };

      reservations = {
        "dhcp" = {
          range = [ "192.168.0.16" "192.168.0.254" ];
          description = "DHCP clients";

          dhcp.valid-lifetime = 31536000;
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
          device = "builder-intel";
          interface = "int";
        };

        "172.23.200.36" = {
          device = "raketensilo";
          interface = "int";
        };

        "172.23.200.37" = {
          device = "win10";
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
          device = "builder-intel";
          interface = "int";
        };

        "fd79:300d:6056:1::3" = {
          device = "raketensilo";
          interface = "int";
        };

        "fd79:300d:6056:1::4" = {
          device = "win10";
          interface = "int";
        };
      };
    };

    # Lab Network @ University
    "10.32.31.0/24" = {
      site = "hs";

      addresses = {
        "10.32.31.29" = {
          device = "paradeplatz";
          interface = "lab";
        };

        "10.32.31.28" = {
          device = "brueckenkopf";
          interface = "lab";
        };

        "10.32.31.30" = {
          device = "raketensilo";
          interface = "lab";
        };
      };

      routes = [
        {
          destination = "193.174.29.0/26";
          gateway = "10.32.31.1";
        }
      ];
    };
  };
}
