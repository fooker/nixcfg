{
  network = {
    enable = true;
    ipam = true;

    router = true;
  };

  systemd.network = {
    networks = {
      "30-ext" = {
        networkConfig = {
          IPv4Forwarding = "yes";
          IPv6Forwarding = "yes";
        };
      };
      "30-int" = {
        networkConfig = {
          IPv4Forwarding = "yes";
          IPv6Forwarding = "yes";
        };
      };
      "30-lab" = {
        networkConfig = {
          IPv4Forwarding = "yes";
          IPv6Forwarding = "yes";
        };
      };
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.forward = {
      uplink = between [ "established" ] [ "drop" ] ''
        meta iifname int
        meta oifname {lab, ext}
        accept
      '';
    };

    inet.nat.postrouting = {
      uplink = anywhere ''
        meta oifname {lab, ext}
        masquerade
      '';
    };
  };
}
