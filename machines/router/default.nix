let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./pppd.nix
    ./dhcp.nix
    ./corerad.nix
    ./dns.nix
    ./upnp.nix
    ./ddclient.nix
    ./peering.nix
  ];

  serial.enable = true;
  server.enable = true;

  backup.passphrase = secrets.backup.passphrase;

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
