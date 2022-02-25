{ lib, pkgs, config, ... }:

with lib;

{
  sound.enable = true;
  security.rtkit.enable = true;

  services.snapserver = {
    enable = true;
    codec = "flac";
    tcp.enable = true;
    http = {
      enable = true;
      docRoot = "${pkgs.snapcast}/share/snapserver/snapweb/";
    };
    streams = {
      # Start of with an empty set of streeams by default.
      # Each sound source defines its own stream.
    };
  };

  # Local snapclient
  systemd.services.snapclient = {
    after = [ "snapserver.service" "pulseaudio.service" ];
    wants = [ "pulseaudio.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.snapcast ];
    script = ''
      snapclient \
        --hostID 'toiler' \
        --host 127.0.0.1 \
        --player alsa \
        --soundcard default:CARD=AMP \
        --mixer software
    '';
    serviceConfig = {
      DynamicUser = true;
      User = "snapclient";
      Group = "snapclient";
      PrivateTmp = true;
      ProtectHome = true;
      PrivateMounts = true;
      RuntimeDirectory = "snapclient";
      WorkingDirectory = "%t/snapclient";
      SupplementaryGroups = "audio";
      DeviceAllow = "char-alsa rw";
    };
    environment.HOME = "%t/snapclient";
  };

  reverse-proxy.hosts = {
    "snapserver" = {
      domains = [ "sound.home.open-desk.net" ];
      target = "http://[::1]:${toString config.services.snapserver.http.port}";
    };
  };
}
