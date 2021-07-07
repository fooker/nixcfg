let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./pppd.nix
    ./dns.nix
    ./ddclient.nix
    ./peering.nix
    ./hass.nix
  ];

  serial.enable = true;
  server.enable = true;

  backup.passphrase = secrets.backup.passphrase;

  dns.host = {
    realm = "home";
    ipv4 = "172.23.200.129";
    ipv6 = "fd79:300d:6056:100::0";
  };

  # Legacy host entry for "basis"
  dns.zones = {
    net.open-desk.dev.basis = {
      CNAME = "basis.ddserver.org.";
    };
  };
}
