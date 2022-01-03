{
  services.ipfs = {
    enable = true;

    localDiscovery = false;

    emptyRepo = true;
    autoMount = true;

    apiAddress = "/ip4/10.200.100.2/tcp/5001";
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
