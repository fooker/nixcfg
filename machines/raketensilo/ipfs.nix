{
  services.kubo = {
    enable = true;

    localDiscovery = false;

    emptyRepo = true;
    autoMount = true;
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      ipfs-peers = between [ "established" ] [ "drop" ] [
        ''tcp dport 4001 accept''
        ''udp dport 4001 accept''
      ];
    };
  };
}
