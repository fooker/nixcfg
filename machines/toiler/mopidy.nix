{ pkgs, ... }:

let
  secrets = import ./secrets.nix;
in
{
  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-mpd
      mopidy-local
      mopidy-somafm
      mopidy-musicbox-webclient
    ];
    configuration = ''
      [audio]
      mixer = none
      output = audioresample ! audioconvert ! audio/x-raw,rate=48000,channels=2,format=S16LE ! filesink location=/run/snapserver/mopidy

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
      hostname = ::1
      port = 6680
      zeroconf = Mopidy HTTP Server
      csrf_protection = true
      default_app = musicbox_webclient

      [musicbox_webclient]
      enabled = true
      musicbox = false

      [mpd]
      enabled = true
      hostname = ::
      port = 6600
      password = ${secrets.mopidy.mpd.password}
      zeroconf = Mopidy MPD Server

      [file]
      enabled = false

      [local]
      enabled = true
      media_dir = /mnt/media/music

      [m3u]
      enabled = false

      [somafm]
      enabled = true
      encoding = aac
      quality = highest
    '';
  };

  systemd.timers.mopidy-scan = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = [ "*-*-* 05:00:00" ];
  };

  systemd.services.mopidy.unitConfig = {
    RequiresMountsFor = "/mnt/media";
  };

  systemd.services.mopidy.after = [ "snapserver.service" ];

  services.snapserver.streams = {
    "mopidy" = {
      type = "pipe";
      location = "/run/snapserver/mopidy";
      codec = "pcm";
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      mopidy = between [ "established" ] [ "drop" ] ''
        ip saddr 172.23.200.0/24
        tcp dport 6600
        accept
      '';
    };
  };

  reverse-proxy.hosts = {
    "mopidy" = {
      domains = [ "mopidy.home.open-desk.net" ];
      target = "http://[::1]:6680";
    };
  };

  backup.paths = [
    "/var/lib/mopidy"
  ];
}
