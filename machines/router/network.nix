{ config, lib, pkgs, machine, ... }:

{
  systemd.network = {
    enable = true;

    links = {
      "00-en-l" = {
        matchConfig = {
          MACAddress = "52:54:00:58:89:b4";
          #MACAddress = "00:0d:b9:34:db:e4";
          #Path = "pci-0000:01:00.0";
        };
        linkConfig = {
          Name = "en-l";
        };
      };
      
      "00-en-r" = {
        matchConfig = {
          MACAddress = "52:54:00:58:89:b5";
          #MACAddress = "00:0d:b9:34:db:e5";
          #Path = "pci-0000:02:00.0";
        };
        linkConfig = {
          Name = "en-r";
        };
      };
      
      "00-modem" = {
        matchConfig = {
          MACAddress = "52:54:00:58:89:b6";
          #MACAddress = "00:0d:b9:34:db:e6";
          #Path = "pci-0000:03:00.0";
        };
        linkConfig = {
          Name = "modem";
        };
      };
    };

    netdevs = {
      "00-dsl" = {
        netdevConfig = {
          Name = "dsl";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 7;
        };
      };

      "00-int" = {
        netdevConfig = {
          Name = "int";
          Kind = "bond";
        };
        bondConfig = {
          Mode = "802.3ad";
        };
      };
      
      "10-mngt-vlan" = {
        netdevConfig = {
          Name = "mngt-vlan";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 1;
        };
      };
      
      "10-priv-vlan" = {
        netdevConfig = {
          Name = "priv-vlan";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 2;
        };
      };
      
      "10-guest-vlan" = {
        netdevConfig = {
          Name = "guest-vlan";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 3;
        };
      };

      "20-mngt" = {
        netdevConfig = {
          Name = "mngt";
          Kind = "bridge";
        };
      };

      "20-priv" = {
        netdevConfig = {
          Name = "priv";
          Kind = "bridge";
        };
      };

      "20-guest" = {
        netdevConfig = {
          Name = "guest";
          Kind = "bridge";
        };
      };
    };

    networks = {
      "00-en-l" = {
        name = "en-l";
        bond = [ "int" ];
      };

      "00-en-r" = {
        name = "en-r";
        bond = [ "int" ];
      };

      "00-modem" = {
        name = "modem";
        bridge = [ "mngt" ];
        vlan = [ "dsl" ];
      };

      "10-int" = {
        name = "int";
        vlan = [ "mngt-vlan" "priv-vlan" "guest-vlan" ];
      };

      "20-mngt-vlan" = {
        name = "mngt-vlan";
        bridge = [ "mngt" ];
      };

      "20-priv-vlan" = {
        name = "priv-vlan";
        bridge = [ "priv" ];
      };

      "20-guest-vlan" = {
        name = "guest-vlan";
        bridge = [ "guest" ];
      };

      "30-mngt" = {
        name = "mngt";
        address = [ "192.168.254.1/24" ];
      };

      "30-priv" = {
        name = "priv";
        address = [ "172.200.172.129/25" ];
      };

      "30-guest" = {
        name = "priv";
        address = [ "203.0.113.1/24" ];
      };
    };
  };
}
