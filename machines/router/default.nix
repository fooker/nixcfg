{
  imports = [
    ./hardware.nix
    ./network.nix
    ./pppd.nix
    ./dhcp.nix
    ./corerad.nix
    ./dns.nix
    ./ntp.nix
    ./upnp.nix
    ./ddclient.nix
    ./peering.nix
  ];

  serial.enable = true;
  server.enable = true;

  dns.host = {
    realm = "home";
    interface = "priv";
  };

  # Legacy host entry for "basis"
  dns.zones = {
    net.open-desk.dev.basis = {
      CNAME = "basis.ddserver.org.";
    };
  };
}
