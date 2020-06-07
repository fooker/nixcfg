{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;

  mopidy-jellyfin = pkgs.callPackage ../../packages/mopidy-jellyfin.nix {};
  mopidy-mpd = pkgs.callPackage ../../packages/mopidy-mpd.nix {};
  mopidy-muse = pkgs.callPackage ../../packages/mopidy-muse.nix {};
  mopidy-somafm = pkgs.callPackage ../../packages/mopidy-somafm.nix {};
in {
  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-spotify
      mopidy-jellyfin
      mopidy-mpd
      mopidy-muse
      mopidy-somafm
    ];
    configuration = ''
      [audio]
      mixer = none
      output = pulsesink

      [stream]
      enabled = true
      protocols =
          http
          https
          mms
          rtmp
          rtmps
          rtsp

      [http]
      enabled = true
      hostname = ::
      port = 6680
      zeroconf = Mopidy HTTP Server
      csrf_protection = true
      default_app = muse

      [muse]
      enabled = true

      [mpd]
      enabled = true
      hostname = ::
      port = 6600
      password = ${secrets.mopidy.mpd.password}
      zeroconf = Mopidy MPD Server

      [file]
      enabled = false

      [m3u]
      enabled = false

      [jellyfin]
      enabled = true
      hostname = http://localhost:8096
      username = ${secrets.mopidy.jellyfin.username}
      password = ${secrets.mopidy.jellyfin.password}
      album_format = {ProductionYear} - {Name}

      [spotify]
      enabled = true
      username = ${secrets.mopidy.spotify.username}
      password = ${secrets.mopidy.spotify.username}
      client_id = ${secrets.mopidy.spotify.client_id}
      client_secret = ${secrets.mopidy.spotify.client_secret}
      bitrate = 320
      volume_normalization = true

      [somafm]
      enabled = true
      encoding = aac
      quality = highest
    '';
  };

  networking.firewall.interfaces = {
    "priv" = {
      allowedTCPPorts = [ 6600 6680 ];
    };
  };

  backup.paths = [
    "/var/lib/mopidy"
  ];
}