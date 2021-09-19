let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./octoprint.nix
  ];

  serial.enable = true;
  server.enable = true;

  backup.passphrase = secrets.backup.passphrase;

  dns.host = {
    realm = "home";
    interface = "priv";
  };
}
