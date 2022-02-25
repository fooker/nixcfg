{ lib, pkgs, ... }:

with lib;

let
  secrets = import ./secrets.nix;
in
{
  services.snapserver.streams = {
    "spotify" = {
      type = "librespot";
      location = "${pkgs.librespot}/bin/librespot";
      query = {
        username = "${secrets.spotify.username}";
        password = "${secrets.spotify.password}";
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
