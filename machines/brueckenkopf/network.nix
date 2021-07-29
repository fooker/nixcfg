{
  network = {
    enable = true;
    ipam = true;
  };

  systemd.network = {
    networks = {
      "30-ext" = {
        networkConfig = {
          IPForward = "yes";
        };
      };
      "30-int" = {
        networkConfig = {
          IPForward = "yes";
        };
      };
      "30-lab" = {
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
