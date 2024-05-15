{
  imports = [
    ./hardware.nix
    ./network.nix
    ./bitmagnet.nix
  ];

  server.enable = true;

  dns.host = {
    interface = "ext";
  };
}
