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
    };
  };
}
