let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
  ];

  server.enable = true;

  backup.passphrase = secrets.backup.passphrase;
}