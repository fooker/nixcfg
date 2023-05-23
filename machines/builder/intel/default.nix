{
  imports = [
    ./hardware.nix
    ./network.nix
  ];

  server.enable = true;

  builder = {
    enable = true;
    emulatedSystems = [ "aarch64-linux" ];
  };

  dns.host = {
    realm = "hs";
    interface = "int";
  };
}
