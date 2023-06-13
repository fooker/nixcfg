{
  imports = [
    ./hardware.nix
    ./network.nix
    ./magnetico.nix
  ];

  server.enable = true;

  dns.host = {
    interface = "ext";
  };
}
