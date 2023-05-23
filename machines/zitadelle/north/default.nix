{ config, ... }:

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
    spouse = config.hive.nodes.zitadelle-south;
  };

  dns.host = {
    interface = "ext";
  };
}
