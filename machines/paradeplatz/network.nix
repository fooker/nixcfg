{
  network = {
    enable = true;
    ipam = true;

    interfaces = {
      "lab-raw" = "44:8a:5b:a6:04:04";
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

      "30-int" = {
        networkConfig = {
          IPForward = "yes";
        };
      };
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.forward = {
      uplink = between [ "established" ] [ "drop" ] ''
        meta iifname int
        meta oifname lab
        accept
      '';
    };

    inet.nat.postrouting = {
      uplink = anywhere ''
        meta oifname "lab"
        masquerade
      '';
    };
  };
}
