{ lib, config, device, network, ... }:

with lib;

let
  networks = {
    mngt = {
      vlan = 1;
      inherit (device.interfaces.mngt.address) ipv4;
    };
    priv = {
      vlan = 2;
      inherit (device.interfaces.priv.address) ipv4 ipv6;
    };
    guest = {
      vlan = 3;
      inherit (device.interfaces.guest.address) ipv4;
    };
    iot = {
      vlan = 4;
      inherit (device.interfaces.iot.address) ipv4;
    };
  };
in
{
  network = {
    enable = true;

    interfaces = {
      "int-l" = "00:0d:b9:34:db:e4";
      "int-r" = "00:0d:b9:34:db:e5";
      "dsl" = "00:0d:b9:34:db:e6";
    };
  };

  systemd.network = mkMerge ([{
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

        linkConfig = {
          RequiredForOnline = "routable";
        };

        networkConfig = {
          DNS = "127.0.0.1";

          IPv6AcceptRA = true;
          DHCP = "ipv6";

          IPForward = "yes";

          IPv6PrivacyExtensions = "kernel";
          IPv6DuplicateAddressDetection = 1;

          KeepConfiguration = "static";
        };

        dhcpV6Config = {
          UseDNS = false;
          UseNTP = false;

          WithoutRA = "solicit";

          PrefixDelegationHint = "::/56";
        };
      };
    };
  }] ++ (mapAttrsToList
    (name: config: {
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
            (optional (hasAttr "ipv4" config) (toString config.ipv4))
            (optional (hasAttr "ipv6" config) (toString config.ipv6))
          ];

          networkConfig = {
            DHCPPrefixDelegation = true;
            IPv6SendRA = true;

            IPv6DuplicateAddressDetection = 1;
            IPv6PrivacyExtensions = false;
            IPv6AcceptRA = false;

            DNS = "${toString config.ipv4.address}";
            Domains = [
              "home.open-desk.net"
              "${name}.home.open-desk.net"
            ];

            IPForward = "yes";
          };

          ipv6Prefixes = optional (hasAttr "ipv6" config) {
            ipv6PrefixConfig = {
              Prefix = toString (ip.network.prefixNetwork config.ipv6);
            };
          };

          dhcpV6PrefixDelegationConfig = {
            UplinkInterface = "ppp0";
            Assign = true;
            Announce = true;
            SubnetId = config.vlan;
          };
        };
      };
    })
    networks));

  firewall.rules =
    let
      nas = {
        ipv4 = toString network.devices."nas".interfaces."priv".address.ipv4.address;
        ipv6 = toString network.devices."nas".interfaces."priv".address.ipv6.address;
      };
    in
    dag: with dag; {
      inet.nat.prerouting.forward-torrent = anywhere [
        ''meta iifname "ppp*" tcp dport 6242 dnat ip to ${nas.ipv4}:6242''
        ''meta iifname "ppp*" udp dport 6242 dnat ip to ${nas.ipv4}:6242''
        ''meta iifname "ppp*" tcp dport 6242 dnat ip6 to ${nas.ipv6}:6242''
        ''meta iifname "ppp*" udp dport 6242 dnat ip6 to ${nas.ipv6}:6242''
      ];

      inet.filter.forward.forward-torrent = before [ "drop" ] [
        ''meta iifname "ppp*" ip daddr "${nas.ipv4}" tcp dport 6242 accept''
        ''meta iifname "ppp*" ip daddr "${nas.ipv4}" udp dport 6242 accept''
        ''meta iifname "ppp*" ip6 daddr "${nas.ipv6}" tcp dport 6242 accept''
        ''meta iifname "ppp*" ip6 daddr "${nas.ipv6}" udp dport 6242 accept''
      ];

      inet.filter.forward = {
        uplink = between [ "established" ] [ "drop" ] ''
          meta iifname { mngt, priv, guest }
          meta oifname "ppp*"
          accept
        '';

        priv2guest = between [ "established" ] [ "drop" ] ''
          meta iifname priv
          meta oifname { guest, iot }
          accept
        '';

        filter-priv = between [ "established" ] [ "peering-dn42" ] [
          ''
            ip saddr != { ${concatMapStringsSep "," toString config.peering.domains.dn42.exports.ipv4} }
            meta oifname { priv }
            drop
          ''
          ''
            ip6 saddr != { ${concatMapStringsSep "," toString config.peering.domains.dn42.exports.ipv6} }
            meta oifname { priv }
            drop
          ''
        ];
      };

      inet.filter.input = {
        uplink-dhcpv6 = between [ "established" ] [ "drop" ] ''
          udp sport dhcpv6-server
          udp dport dhcpv6-client
          accept
        '';
      };
    };

  networking.firewall.connectionTrackingModules = [ "sip" ];
}
