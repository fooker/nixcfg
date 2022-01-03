let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./ipfs.nix
  ];

  server.enable = true;

  backup.passphrase = secrets.backup.passphrase;

  dns.host = {
    realm = "hs";
    interface = "int";
  };
}
