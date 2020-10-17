{ config, lib, pkgs, ... }:

# TODO: Make vx vlan config not so special
# TODO: Make vxlan group address a real hex value...

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
  systemd.package = pkgs.systemd.overrideAttrs (oldAttrs: rec {
    name = "systemd-vxlan";
    patches = [
      (pkgs.fetchpatch {
        name = "systemd-vxlan-group.patch";
        url = "https://github.com/systemd/systemd/pull/15397.patch";
        sha256 = "1n9rv9wf0kbxrrzzb40hrqbs85crf9qkh1yl1pjpsf619w827kay";
      })
    ];
  });

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

      "15-vx" = {
        name = "vx";
        vxlan = (map (name: "${name}-vxlan") (attrNames networks));
        networkConfig = {
          LinkLocalAddressing = "ipv6";
        };
      };

      "40-uplink" = {
        name = "ppp0";
        networkConfig = {
          DNS = "127.0.0.1";

          IPv6AcceptRA = true;
          DHCP = "ipv6";

          IPv6PrefixDelegation = "dhcpv6";
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
        extraConfig = ''
          [IPv6PrefixDelegation]
          Managed = true
          OtherInformation = true
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

      "25-${name}-vxlan" = {
        netdevConfig = {
          Name = "${name}-vxlan";
          Kind = "vxlan";
        };

        extraConfig = ''
          [VXLAN]
          VNI = ${toString config.vlan}
          Group = ff02::42:${toString config.vlan}
          DestinationPort = 8472
          MacLearning = true
        '';
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

      "25-${name}-vxlan" = {
        name = "${name}-vxlan";
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
          # IPv6PrefixDelegation = "dhcpv6";
          DNS = "${config.address}";
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

          DNS = "${config.address}";
        };

        # extraConfig = ''
        #   [IPv6PrefixDelegation]
        #   Managed = true
        #   OtherInformation = true
        # '';
      };
    };
  }) networks);

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
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
      established = before ["drop"] ''
        ct state {
          established,
          related
        }
        accept
      '';

      uplink = between ["established"] ["drop"] ''
        meta iifname { mngt, priv, guest }
        meta oifname "ppp*"
        accept
      '';

      priv2guest = between ["established"] ["drop"] ''
        meta iifname priv
        meta oifname guest
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

      # TODO: Limit to "daddr=fe80::/10 dport=546" and "saddr=fe80::/10 sport=547"
      uplink-dhcpv6 = between ["established"] ["drop"] ''
        udp dport { dhcpv6-client, dhcpv6-server }
        accept
      '';

      vx = between ["established"] ["drop"] ''
        meta iifname mngt
        udp dport vxlan
      '';
    };
  };
}
