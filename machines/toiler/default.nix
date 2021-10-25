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

  backup.passphrase = secrets.backup.passphrase;

  dns.host = {
    realm = "home";
    interface = "priv";
  };
}
