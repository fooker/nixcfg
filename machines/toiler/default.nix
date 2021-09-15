let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./jellyfin.nix
    ./pulseaudio.nix
    ./mopidy.nix
    ./spotifyd.nix
    ./user.nix
    ./gitea.nix
    ./drone.nix
    ./paperless.nix
    ./hass.nix
  ];

  server.enable = true;
  builder.enable = true;

  backup.passphrase = secrets.backup.passphrase;

  dns.host = {
    realm = "home";
    ipv4 = "172.23.200.131";
    ipv6 = "fd79:300d:6056:100::2";
  };
}
