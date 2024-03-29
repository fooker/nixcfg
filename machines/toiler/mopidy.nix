{ pkgs, private, ... }:

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
      password = ${private.mpd.password}
      zeroconf = Mopidy MPD Server

      [file]
      enabled = true
      media_dirs =
              /mnt/media/music|Music
              /mnt/downloads/c3sets|c3sets
      follow_symlinks = true

      [local]
      enabled = true
      media_dir = /mnt/media/music

      [m3u]
      enabled = true

      [somafm]
      enabled = true
      encoding = aac
      quality = highest
    '';
  };

  systemd.services.mopidy-scan = {
    startAt = "5:00";
  };

  systemd.services.mopidy = {
    after = [ "snapserver.service" ];
    unitConfig = {
      RequiresMountsFor = "/mnt/media";
    };
  };

  services.snapserver.streams = {
    "mopidy" = {
      type = "pipe";
      location = "/run/snapserver/mopidy";
      codec = "pcm";
    };
  };

  systemd.services.c3sets-playlist = {
    script = ''
      find /mnt/downloads/c3sets/by-id -type f > /var/lib/mopidy/.local/share/mopidy/m3u/c3sets.m3u8
    '';
    startAt = "7:00";
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

  web.reverse-proxy = {
    "mopidy" = {
      domains = [ "mopidy.home.open-desk.net" ];
      target = "http://[::1]:6680";
    };
  };

  backup.paths = [
    "/var/lib/mopidy"
  ];
}
