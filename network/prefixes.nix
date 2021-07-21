{
  prefixes = {
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

    "172.23.200.32/28" = {
      site = "university";

      gateway = "172.23.200.33";

      addresses = {
        "172.23.200.33" = {
          device = "brueckenkopf";
          interface = "int";
        };

        # "172.23.200.34" = {
        #   device = "paradeplatz";
        #   interface = "int";
        # };

        # "172.23.200.35" = {
        #   device = "builder";
        #   interface = "int";
        # };
      };
    };

    "fd79:300d:6056:1::/64" = {
      site = "university";

      gateway = "fd79:300d:6056:1::";

      addresses = {
        "fd79:300d:6056:1::" = {
          device = "brueckenkopf";
          interface = "int";
        };
      };
    };

    "192.168.42.0/24" = {
      site = "university";

      gateway = "192.168.42.1";
      dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];

      addresses = {
        "192.168.42.2" = {
          device = "builder";
          interface = "int";
        };
      };
    };

    "192.168.31.0/24" = {
      site = "university";

      #gateway = "192.168.31.1";
      #dns = [ ];

      addresses = {
        "192.168.31.28" = {
          device = "paradeplatz";
          interface = "lab";
        };
        "192.168.31.93" = {
          device = "brueckenkopf";
          interface = "lab";
        };
      };
    };
  };
}
