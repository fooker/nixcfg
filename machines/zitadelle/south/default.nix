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
    spouse = config.hive.nodes.zitadelle-north;
  };

  dns.host = {
    interface = "ext";
  };
}
