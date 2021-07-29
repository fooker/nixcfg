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
    realm = "hs";
    ipv4 = "172.23.200.35";
    ipv6 = "fd79:300d:6056:1::2";
  };
}
