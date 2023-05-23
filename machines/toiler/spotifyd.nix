{ lib, pkgs, private, ... }:

with lib;

{
  services.snapserver.streams = {
    "spotify" = {
      type = "librespot";
      location = "${pkgs.librespot}/bin/librespot";
      query = {
        username = "${private.spotify.username}";
        password = "${private.spotify.password}";
        devicename = "toiler";
        bitrate = "320";
        normalize = "true";
        autoplay = "true";
        zeroconf_port = "4444";
      };
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      spotify = between [ "established" ] [ "drop" ] ''
        ip saddr 172.23.200.0/24
        tcp dport 4444
        accept
      '';
    };
  };
}
