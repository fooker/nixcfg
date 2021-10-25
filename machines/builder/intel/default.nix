let
  secrets = import ./secrets.nix;
in
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

  backup.passphrase = secrets.backup.passphrase;

  dns.host = {
    realm = "hs";
    interface = "int";
  };
}
