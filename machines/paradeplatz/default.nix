{
  imports = [
    ./hardware.nix
    ./network.nix
    ./libvirt.nix
  ];

  server.enable = true;

  dns.host = {
    realm = "hs";
    interface = "int";
  };
}
