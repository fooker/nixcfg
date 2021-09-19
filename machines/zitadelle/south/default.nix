{ config, ... }:

let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./peering.nix
    ../.
  ];

  server.enable = true;

  hive = {
    enable = true;
    spouse = config.hive.nodes.zitadelle-north;
  };

  backup.passphrase = secrets.backup.passphrase;

  dns.host = {
    interface = "ext";
  };
}
