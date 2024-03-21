{
  networking.networkmanager = {
    enable = true;
    unmanaged = [
      "interface-name:dn42"
      "interface-name:peer.*"
      "interface-name:virbr*"
      "interface-name:docker*"
      "interface-name:br-*"
      "interface-name:en-port"
      "interface-name:en-dock"
    ];
    dns = "systemd-resolved";
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.ignore_routes_with_linkdown" = 1;
    "net.ipv6.conf.all.ignore_routes_with_linkdown" = 1;
  };

  systemd.network = {
    enable = true;

    links = {
      "00-en-port" = {
        matchConfig = {
          MACAddress = "74:5d:22:b8:62:c5";
          Type = "ether";
        };
        linkConfig = {
          Name = "en";
        };
      };
      "00-en-dock" = {
        matchConfig = {
          MACAddress = "38:7c:76:1a:89:f0";
          Type = "ether";
        };
        linkConfig = {
          Name = "en";
        };
      };
    };

    netdevs = {
      "10-en" = {
        netdevConfig = {
          Name = "en";
          Kind = "bridge";
        };
      };
    };

    networks = {
      "00-en" = {
        matchConfig = {
          Name = "en-*";
        };
        bridge = [ "en" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };
      "10-en" = {
        name = "en";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 300;
        };
      };
    };

    wait-online.enable = false;
  };

  firewall.rules = dag: with dag; {
    bridge.filter.forward = {
      accept = anywhere ''
        accept
      '';
    };
  };

  networking.nftables.checkRuleset = false; # Disabled, because build environment can not handle bridge rules

  systemd.services.systemd-networkd-wait-online.enable = false;
}
