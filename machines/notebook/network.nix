{
  networking.networkmanager = {
    enable = true;
    unmanaged = [
      "interface-name:dn42"
      "interface-name:peer.*"
      "interface-name:virbr*"
      "interface-name:docker*"
      "interface-name:br-*"
    ];
    dns = "systemd-resolved";
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.ignore_routes_with_linkdown" = 1;
    "net.ipv6.conf.all.ignore_routes_with_linkdown" = 1;
  };

  systemd.network = {
    enable = true;

    links = {
      "00-en" = {
        matchConfig = {
          MACAddress = "74:5d:22:b8:62:c5";
          Type = "ether";
        };
        linkConfig = {
          Name = "en";
        };
      };
    };

    wait-online.enable = false;
  };

  systemd.services.systemd-networkd-wait-online.enable = false;
}
