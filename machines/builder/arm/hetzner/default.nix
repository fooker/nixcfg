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
    ipv4 = null;
    ipv6 = "2a01:4f8:c014:e26e::1";
  };
}
