{
  network = {
    enable = true;
    ipam = true;

    interfaces = {
      "int" = "38:f7:cd:c6:49:9f";
    };
  };

  systemd.network = {
    netdevs = {
      "20-priv-vlan" = {
        netdevConfig = {
          Name = "priv-vlan";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 2;
        };
      };

      "20-iot-vlan" = {
        netdevConfig = {
          Name = "iot-vlan";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 4;
        };
      };

      "30-priv" = {
        netdevConfig = {
          Name = "priv";
          Kind = "bridge";
        };
      };

      "30-iot" = {
        netdevConfig = {
          Name = "iot";
          Kind = "bridge";
        };
      };
    };

    networks = {
      "10-int" = {
        name = "int";
        vlan = [ "priv-vlan" "iot-vlan" ];
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

      "20-iot-vlan" = {
        name = "iot-vlan";
        bridge = [ "iot" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };

      "30-iot" = {
        ipv6AcceptRAConfig = {
          # Disable routing over IoT network as it does not provide internet access
          UseGateway = false;
        };
      };
    };
  };
}
