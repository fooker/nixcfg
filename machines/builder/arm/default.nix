let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
  ];

  server.enable = true;
  builder.enable = true;

  backup.passphrase = secrets.backup.passphrase;

  dns.host = {
    interface = "ext";
    ipv4 = "130.61.143.36";
    ipv6 = null;
  };
}
