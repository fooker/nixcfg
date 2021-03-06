{ config, lib, pkgs, ... }:

with lib;

let
  networks = {
    mngt = {
      vlan = 1;
      
      ipv4.address = "192.168.254.1";
      ipv4.prefixLength = 24;

      dhcpPoolOffset = 128;
    };
    priv = {
      vlan = 2;

      ipv4.address = "172.23.200.129";
      ipv4.prefixLength = 25;

      ipv6.address = "fd79:300d:6056:100::";
      ipv6.prefixLength = 64;

      dhcpPoolOffset = 32;
    };
    guest = {
      vlan = 3;

      ipv4.address = "203.0.113.1";
      ipv4.prefixLength = 24;

      dhcpPoolOffset = 16;
    };
    iot = {
      vlan = 4;

      ipv4.address = "192.168.0.1";
      ipv4.prefixLength = 24;

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
      "10-int" = {
        netdevConfig = {
          Name = "int";
          Kind = "bond";
        };
        bondConfig = {
          Mode = "802.3ad";
          TransmitHashPolicy = "layer3+4";
          LACPTransmitRate = "fast";
        };
      };

      "15-vx" = {
        netdevConfig = {
          Name = "vx";
          Kind = "vlan";
        };

        vlanConfig = {
          Id = 100;
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
        vlan = (map (name: "${name}-vlan") (attrNames networks)) ++ [ "vx" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "40-uplink" = {
        name = "ppp0";
        networkConfig = {
          DNS = "127.0.0.1";

          IPv6AcceptRA = true;
          DHCP = "ipv6";
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
        extraConfig = ''
          [Network]
          KeepConfiguration = static

          IPv6PrivacyExtensions = kernel
          IPv6DuplicateAddressDetection = 1

          [DHCPv6]
          UseDNS = false
          UseNTP = false

          ForceDHCPv6PDOtherInformation = yes
          PrefixDelegationHint = 56
        '';
      };
    };
  } (mapAttrsToList (name: config: {
    netdevs = {
      "20-${name}-vlan" = {
        netdevConfig = {
          Name = "${name}-vlan";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = config.vlan;
        };
      };

      "30-${name}" = {
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
        address = concatLists [
          (optional (hasAttr "ipv4" config) "${config.ipv4.address}/${toString config.ipv4.prefixLength}")
          (optional (hasAttr "ipv6" config) "${config.ipv6.address}/${toString config.ipv6.prefixLength}")
        ];

        networkConfig = {
          DHCPServer = true;

          IPv6PrefixDelegation = "dhcpv6";

          DNS = "${config.ipv4.address}";
          Domains = [
            "home.open-desk.net"
            "${name}.home.open-desk.net"
          ];
        };

        # TODO: Search domain = home.open-desk.net
        dhcpServerConfig = {
          PoolOffset = config.dhcpPoolOffset;

          EmitDNS = true;
          EmitNTP = true;
          EmitRouter = true;
          EmitTimezone = true;

          DNS = "${config.ipv4.address}";
        };

        extraConfig = ''
          [Network]
          IPv6DuplicateAddressDetection = 1
          IPv6PrivacyExtensions = no

          [IPv6PrefixDelegation]
          RouterLifetimeSec = 60
          OtherInformation = true

          [DHCPv6PrefixDelegation]
          Assign = yes
        '';
      };
    };
  }) networks);

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = mkForce true;
    "net.ipv4.conf.default.forwarding" = mkForce true;
    "net.ipv6.conf.all.forwarding" = mkForce true;
    "net.ipv6.conf.default.forwarding" = mkForce true;
  };

  firewall.rules = dag: with dag; {
    inet.nat.prerouting = {
      forward-torrent-tcp = anywhere ''
        meta iifname "ppp*"
        tcp dport 6242
        dnat ip to 172.23.200.130:6242
      '';

      forward-torrent-udp = anywhere ''
        meta iifname "ppp*"
        udp dport 6242
        dnat ip to 172.23.200.130:6242
      '';
    };

    inet.filter.forward = {
      uplink = between ["established"] ["drop"] ''
        meta iifname { mngt, priv, guest }
        meta oifname "ppp*"
        accept
      '';

      priv2guest = between ["established"] ["drop"] ''
        meta iifname priv
        meta oifname { guest, iot }
        accept
      '';

      forward-torrent-tcp = before ["drop"] ''
        meta iifname "ppp*"
        ip daddr "172.23.200.130"
        tcp dport 6242
        accept
      '';

      forward-torrent-udp = before ["drop"] ''
        meta iifname "ppp*"
        ip daddr "172.23.200.130"
        udp dport 6242
        accept
      '';
    };

    inet.filter.input = {
      dhcp = between ["established"] ["drop"] ''
        meta iifname { mngt, priv, guest, iot }
        udp dport bootps
        accept
      '';

      uplink-dhcpv6 = between ["established"] ["drop"] ''
        udp sport dhcpv6-server
        udp dport dhcpv6-client
        accept
      '';
    };
  };
}
