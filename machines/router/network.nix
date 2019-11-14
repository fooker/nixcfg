{ config, lib, pkgs, machine, ... }:

{
  systemd.network = {
    enable = true;

    links = {
      "00-int-l" = {
        matchConfig = {
          MACAddress = "00:0d:b9:34:db:e4";
          Path = "pci-0000:01:00.0";
        };
        linkConfig = {
          Name = "int-l";
        };
      };
      
      "00-int-r" = {
        matchConfig = {
          MACAddress = "00:0d:b9:34:db:e5";
          Path = "pci-0000:02:00.0";
        };
        linkConfig = {
          Name = "int-r";
        };
      };
      
      "00-dsl" = {
        matchConfig = {
          MACAddress = "00:0d:b9:34:db:e6";
          Path = "pci-0000:03:00.0";
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
      
      "10-iot-vlan" = {
        netdevConfig = {
          Name = "iot-vlan";
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
        vlan = [ "mngt-vlan" "priv-vlan" "guest-vlan" "iot-vlan" ];
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

      "20-iot-vlan" = {
        name = "iot-vlan";
        bridge = [ "iot" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "30-mngt" = {
        name = "mngt";
        address = [ "192.168.254.1/24" ];

        networkConfig = {
          DHCPServer = true;
          IPv6PrefixDelegation = "dhcpv6";
          DNS = "192.168.254.1";
        };

        dhcpServerConfig = {
          PoolOffset = 128;

          EmitDNS = true;
          EmitNTP = true;
          EmitRouter = true;
          EmitTimezone = true;

          DNS = "192.168.254.1";
        };

        extraConfig = ''
          [IPv6PrefixDelegation]
          Managed = true
          OtherInformation = true
        '';
      };

      "30-priv" = {
        name = "priv";
        address = [ "172.23.200.129/25" ];

        networkConfig = {
          DHCPServer = true;
          IPv6PrefixDelegation = "dhcpv6";
          DNS = "172.23.200.129";
        };

        dhcpServerConfig = {
          PoolOffset = 32;

          EmitDNS = true;
          EmitNTP = true;
          EmitRouter = true;
          EmitTimezone = true;

          DNS = "172.23.200.129";
        };

        extraConfig = ''
          [IPv6PrefixDelegation]
          Managed = true
          OtherInformation = true
        '';
      };

      "30-guest" = {
        name = "guest";
        address = [ "203.0.113.1/24" ];

        networkConfig = {
          DHCPServer = true;
          IPv6PrefixDelegation = "dhcpv6";
          DNS = "203.0.113.1";
        };

        dhcpServerConfig = {
          PoolOffset = 16;

          EmitDNS = true;
          EmitNTP = true;
          EmitRouter = true;
          EmitTimezone = true;

          DNS = "203.0.113.1";
        };

        extraConfig = ''
          [IPv6PrefixDelegation]
          Managed = true
          OtherInformation = true
        '';
      };

      "30-iot" = {
        name = "iot";
        address = [ "192.168.0.1/24" ];

        networkConfig = {
          DHCPServer = true;
          IPv6PrefixDelegation = "dhcpv6";
          DNS = "192.168.0.1";
        };

        dhcpServerConfig = {
          PoolOffset = 16;

          EmitDNS = true;
          EmitNTP = true;
          EmitRouter = true;
          EmitTimezone = true;

          DNS = "192.168.0.1";
        };

        extraConfig = ''
          [IPv6PrefixDelegation]
          Managed = true
          OtherInformation = true
        '';
      };

      "40-uplink" = {
        name = "ppp0";
        networkConfig = {
          IPv6AcceptRA = true;
          
          # IPMasquerade = true;
          # IPForward = "yes";

          DHCP = "ipv6";
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall = {
    interfaces = lib.genAttrs [ "mngt" "priv" "guest" "iot" ] (iface: {
      allowedUDPPorts = [
        67 # DHCP
      ];
    });
    
    checkReversePath = false;
  };

  networking.nat = {
    enable = true;
    externalInterface = "ppp0";
    internalInterfaces = [
      "mngt"
      "priv"
      "guest"
      "iot"
    ];
  };
}
