{ config, lib, pkgs, machine, ... }:

with lib;

let
  networks = {
    mngt = {
      vlan = 1;
      
      address = "192.168.254.1";
      prefixLength = 24;

      dhcpPoolOffset = 128;
    };
    priv = {
      vlan = 2;

      address = "172.23.200.129";
      prefixLength = 25;

      dhcpPoolOffset = 32;
    };
    guest = {
      vlan = 3;

      address = "203.0.113.1";
      prefixLength = 24;

      dhcpPoolOffset = 16;
    };
    iot = {
      vlan = 4;

      address = "192.168.0.1";
      prefixLength = 24;

      dhcpPoolOffset = 16;
    };
  };
in {
  systemd.network = foldl recursiveUpdate {
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
        vlan = map (name: "${name}-vlan") (attrNames networks);
        networkConfig = {
          LinkLocalAddressing = "no";
        };
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
  } (mapAttrsToList (name: config: {
    netdevs = {
      "10-${name}-vlan" = {
        netdevConfig = {
          Name = "${name}-vlan";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = config.vlan;
        };
      };
    
      "20-${name}" = {
        netdevConfig = {
          Name = "${name}";
          Kind = "bridge";
        };
      };
    };

    networks = {
      "20-${name}-vlan" = {
        name = "${name}-vlan";
        bridge = [ "${name}" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "30-${name}" = {
        name = "${name}";
        address = [ "${config.address}/${toString config.prefixLength}" ];

        networkConfig = {
          DHCPServer = true;
          IPv6PrefixDelegation = "dhcpv6";
          DNS = "${config.address}";
        };

        dhcpServerConfig = {
          PoolOffset = config.dhcpPoolOffset;

          EmitDNS = true;
          EmitNTP = true;
          EmitRouter = true;
          EmitTimezone = true;

          DNS = "${config.address}";
        };

        extraConfig = ''
          [IPv6PrefixDelegation]
          Managed = true
          OtherInformation = true
        '';
      };
    };
  }) networks);

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall = {
    interfaces = lib.genAttrs (attrNames networks) (iface: {
      allowedUDPPorts = [
        67 # DHCP
      ];
    });
    
    checkReversePath = false;
  };

  networking.nat = {
    enable = true;
    externalInterface = "ppp0";
    internalInterfaces = attrNames networks;
  };
}
