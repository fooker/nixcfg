{ config, pkgs, lib, ... }:

with lib;

let
  package = pkgs.pulseaudio.override {
    zeroconfSupport = true;
  };

  configFile = pkgs.writeTextFile {
    name = "default.pa";
    text = ''
      load-module module-device-restore
      load-module module-stream-restore
      load-module module-card-restore

      load-module module-switch-on-port-available

      load-module module-pipe-sink file=/run/snapserver/pulse sink_name="Snapcast" format=s16le rate=48000

      load-module module-native-protocol-tcp auth-ip-acl=172.23.200.128/25;fd79:300d:6056:100::/64

      load-module module-zeroconf-publish

      load-module module-always-sink

      load-module module-intended-roles

      load-module module-suspend-on-idle

      load-module module-filter-heuristics
      load-module module-filter-apply

      set-default-sink Snapcast
    '';
  };
in
{
  users = {
    users."pulse" = {
      uid = config.ids.uids.pulseaudio;
      group = "pulse";
      extraGroups = [ "audio" ];
      description = "PulseAudio system service user";
      home = "/run/pulse";
      createHome = true;
      isSystemUser = true;
    };

    groups."pulse" = {
      gid = config.ids.gids.pulseaudio;
    };
  };

  systemd.services.pulseaudio = {
    description = "PulseAudio System-Wide Server";
    wantedBy = [ "sound.target" ];
    before = [ "sound.target" ];
    after = [ "snapserver.service" ];
    requires = [ "snapserver.service" ];
    environment.PULSE_RUNTIME_PATH = "/run/pulse";
    environment.PULSE_LATENCY_MSEC = toString 60;
    serviceConfig = {
      Type = "notify";
      ExecStart = "${getBin package}/bin/pulseaudio --daemonize=no --log-level=debug --system -n --file=${configFile}";
      Restart = "on-failure";
      RestartSec = "500ms";
    };
  };

  services.dbus.packages = [ package ];

  services.snapserver.streams = {
    "pulse" = {
      type = "pipe";
      location = "/run/snapserver/pulse";
      query = {
        mode = "create";
      };
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      pulseaudio = between [ "established" ] [ "drop" ] ''
        ip saddr 172.23.200.0/24
        tcp dport 4713
        accept
      '';
    };
  };
}
