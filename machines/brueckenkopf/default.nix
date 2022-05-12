let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./peering.nix
    ./mosh.nix
    ./weechat.nix
    ./monitoring
  ];

  server.enable = true;

  backup.passphrase = secrets.backup.passphrase;

  dns.host.interface = "ext";
}
