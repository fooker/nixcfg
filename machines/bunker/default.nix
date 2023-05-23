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

  dns.host.interface = "ext";
}
