{
  services.music-assistant = {
    enable = true;
    providers = [
      "builtin"
      "dlna"
      "filesystem_local"
      "filesystem_smb"
      "hass"
      "hass_players"
      "jellyfin"
      "musicbrainz"
      "radiobrowser"
      "slimproto"
      "snapcast"
      "spotify"
      "theaudiodb"
    ];
  };

  web.reverse-proxy = {
    "mass" = {
      domains = [ "mass.home.open-desk.net" ];
      target = "http://[::1]:8095";
    };
  };
}

