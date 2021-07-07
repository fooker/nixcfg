{
  systemd.network = {
    enable = true;

    links = {
      "00-priv" = {
        matchConfig = {
          MACAddress = "b8:27:eb:cb:20:ed";
        };
        linkConfig = {
          Name = "priv";
        };
      };
    };

    networks = {
      "30-priv" = {
        name = "priv";
        address = [
          "172.23.200.134/25"
        ];
        gateway = [ "172.23.200.129" ];
        dns = [ "172.23.200.129" ];
        domains = [
          "home.open-desk.net"
          "priv.home.open-desk.net"
        ];
      };
    };
  };
}
