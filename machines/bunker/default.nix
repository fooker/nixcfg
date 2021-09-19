let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./peering.nix
    ./dns/default.nix
    ./syncthing.nix
  ];

  server.enable = true;

  hive = {
    enable = true;
  };

  backup.passphrase = secrets.backup.passphrase;

  dns.host.interface = "ext";
}
