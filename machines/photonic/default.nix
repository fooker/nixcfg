{
  imports = [
    ./hardware.nix
    ./network.nix
    #./photonic
  ];

  serial.enable = true;
  server.enable = true;

  dns.host = {
    realm = "home";
    interface = "priv";
  };
}
