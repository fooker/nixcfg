{
  imports = [
    ./hardware.nix
    ./network.nix
    ./magnetico.nix
  ];

  server.enable = true;

  dns.host = {
    realm = "hs";
    interface = "int";
  };
}
