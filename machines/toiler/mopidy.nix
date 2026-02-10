{ pkgs, private, ... }:

let
  mopidy-musicbox-webclient-themed = pkgs.mopidy-musicbox-webclient.overrideAttrs (prev: {
    postPatch = ''
      for f in $(find mopidy_musicbox_webclient/static/ -type f -name '*.css'); do
        sed -i \
          -e "s|#2c3e50|#440071|gi" \
          -e "s|#1abc9c|#b5007f|gi" \
          -e "s|#16a085|#7d004f|gi" \
          "$f"
      done
    '';
  });
in

{
  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-mpd
      mopidy-local
      mopidy-somafm
      mopidy-musicbox-webclient-themed
    ];
    settings = {
      audio = {
        mixer = "none";
        output = "audioresample ! audioconvert ! audio/x-raw,rate=48000,channels=2,format=S16LE ! filesink location=/run/snapserver/mopidy";
      };
      file = {
        enabled = true;
        follow_symlinks = true;
        media_dirs = ''${""}
          /mnt/media/music|Music
          /mnt/downloads/c3sets|c3sets
        '';
      };
      http = {
        csrf_protection = true;
        default_app = "musicbox_webclient";
        enabled = true;
        hostname = "::1";
        port = 6680;
        zeroconf = "Mopidy HTTP Server";
      };
      local = {
        enabled = true;
        media_dir = "/mnt/media/music";
      };
      m3u = {
        enabled = true;
      };
      mpd = {
        enabled = true;
        hostname = "::";
        password = private.mpd.password;
        port = 6600;
        zeroconf = "Mopidy MPD Server";
      };
      musicbox_webclient = {
        enabled = true;
        musicbox = false;
      };
      somafm = {
        enabled = true;
        encoding = "aac";
        quality = "highest";
      };
      stream = {
        enabled = true;
        protocols = ''
          http
          https
          mms
          rtmp
          rtmps
          rtsp
        '';
      };
    };
  };

  systemd.services.mopidy-scan = {
    startAt = "5:00";
  };

  systemd.services.mopidy = {
    unitConfig = {
      RequiresMountsFor = "/mnt/media";
    };
  };

  systemd.tmpfiles.rules = [
    "p+ /run/snapserver/mopidy 666 root root - -"
  ];

  services.snapserver.settings.stream.source = [
    "pipe:///run/snapserver/mopidy?name=mopidy"
  ];

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

  backup.jobs."mopidy".paths = [
    "/var/lib/mopidy"
  ];
}
