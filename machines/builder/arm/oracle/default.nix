{
  imports = [
    ./hardware.nix
    ./network.nix
  ];

  server.enable = true;

  builder = {
    enable = true;
  };

  dns.host = {
    interface = "ext";
    ipv4 = "130.61.143.36";
    ipv6 = null;
  };
}
