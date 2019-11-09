{ config, lib, pkgs, machine, ... }:

{
  systemd.network = {
    enable = true;

    links = {
      "00-int-l" = {
        matchConfig = {
          MACAddress = "52:54:00:58:89:b4";
          #MACAddress = "00:0d:b9:34:db:e4";
          #Path = "pci-0000:01:00.0";
        };
        linkConfig = {
          Name = "int-l";
        };
      };
      
      "00-int-r" = {
        matchConfig = {
          MACAddress = "52:54:00:58:89:b5";
          #MACAddress = "00:0d:b9:34:db:e5";
          #Path = "pci-0000:02:00.0";
        };
        linkConfig = {
          Name = "int-r";
        };
      };
      
      "00-dsl" = {
        matchConfig = {
          MACAddress = "52:54:00:58:89:b6";
          #MACAddress = "00:0d:b9:34:db:e6";
          #Path = "pci-0000:03:00.0";
        };
        linkConfig = {
          Name = "dsl";
        };
      };
    };

    netdevs = {
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
      "00-int-l" = {
        name = "int-l";
        bond = [ "int" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "00-int-r" = {
        name = "int-r";
        bond = [ "int" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "00-dsl" = {
        name = "dsl";
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "10-int" = {
        name = "int";
        vlan = [ "mngt-vlan" "priv-vlan" "guest-vlan" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "20-mngt-vlan" = {
        name = "mngt-vlan";
        bridge = [ "mngt" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "20-priv-vlan" = {
        name = "priv-vlan";
        bridge = [ "priv" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "20-guest-vlan" = {
        name = "guest-vlan";
        bridge = [ "guest" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "30-mngt" = {
        name = "mngt";
        address = [ "192.168.253.1/24" ];

        networkConfig = {
          DHCPServer = true;
          IPv6PrefixDelegation = "dhcpv6";
        };

        dhcpServerConfig = {
          PoolOffset = 100;
          EmitDNS = true;
          EmitNTP = true;
          EmitRouter = true;
          EmitTimezone = true;
        };

        extraConfig = ''
          [IPv6PrefixDelegation]
          Managed = true;
          OtherInformation = true;
        '';
      };

      "30-priv" = {
        name = "priv";
        address = [ "172.23.200.129/25" ];

        networkConfig = {
          DHCPServer = true;
          IPv6PrefixDelegation = "dhcpv6";
        };

        dhcpServerConfig = {
          PoolOffset = 100;
          EmitDNS = true;
          EmitNTP = true;
          EmitRouter = true;
          EmitTimezone = true;
        };

        extraConfig = ''
          [IPv6PrefixDelegation]
          Managed = true;
          OtherInformation = true;
        '';
      };

      "30-guest" = {
        name = "guest";
        address = [ "203.0.113.1/24" ];

        networkConfig = {
          DHCPServer = true;
          IPv6PrefixDelegation = "dhcpv6";
        };

        dhcpServerConfig = {
          PoolOffset = 100;
          EmitDNS = true;
          EmitNTP = true;
          EmitRouter = true;
          EmitTimezone = true;
        };

        extraConfig = ''
          [IPv6PrefixDelegation]
          Managed = true;
          OtherInformation = true;
        '';
      };

      "40-uplink" = {
        name = "uplink";
        networkConfig = {
          IPv6AcceptRA = true;
          
          IPMasquerade = true;
          IPForward = "yes";

          DHCP = "ipv6";
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
      };
    };
  };
}
