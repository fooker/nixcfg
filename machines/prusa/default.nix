{
  imports = [
    ./hardware.nix
    ./network.nix
    ./octoprint.nix
  ];

  serial.enable = true;
  server.enable = true;

  dns.host = {
    realm = "home";
    interface = "priv";
  };
}
