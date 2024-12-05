{
  network = {
    enable = true;
    ipam = true;

    interfaces = {
      "lab-raw" = "00:d8:61:c6:16:6c";
    };
  };

  systemd.network = {
    netdevs = {
      "20-int-vlan" = {
        netdevConfig = {
          Name = "int-vlan";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 904;
        };
      };

      "30-lab" = {
        netdevConfig = {
          Name = "lab";
          Kind = "bridge";
        };
      };

      "30-int" = {
        netdevConfig = {
          Name = "int";
          Kind = "bridge";
        };
      };

      "40-priv" = {
        netdevConfig = {
          Name = "priv";
          Kind = "bridge";
        };
      };

      "45-priv-vx" = {
        netdevConfig = {
          Name = "priv-vx";
          Kind = "vxlan";
        };

        vxlanConfig = {
          VNI = 4789;
          Remote = "172.23.200.129";
          Local = "172.23.200.34";
          DestinationPort = 4789;
          Independent = true;
        };
      };
    };

    networks = {
      "10-lab-raw" = {
        name = "lab-raw";
        bridge = [ "lab" ];
        vlan = [ "int-vlan" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "20-int-vlan" = {
        name = "int-vlan";
        bridge = [ "int" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "40-priv" = {
        name = "priv";
      };

      "45-priv-vx" = {
        name = "priv-vx";
        bridge = [ "priv" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      priv-vx = between [ "established" ] [ "drop" ] ''
        ip saddr 172.23.200.129
        udp dport 4789
        accept
      '';
    };
  };
}
