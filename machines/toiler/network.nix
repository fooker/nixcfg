{
  network = {
    enable = true;
    ipam = true;

    interfaces = {
      "priv-raw" = "b8:ae:ed:7d:69:ab";
    };
  };

  systemd.network = {
    netdevs = {
      "30-priv" = {
        netdevConfig = {
          Name = "priv";
          Kind = "bridge";
        };
      };
    };

    networks = {
      "20-priv-raw" = {
        name = "priv-raw";
        bridge = [ "priv" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };
    };
  };
}
