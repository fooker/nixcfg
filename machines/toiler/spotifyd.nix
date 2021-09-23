{ lib, ... }:

with lib;

let
  secrets = import ./secrets.nix;
in
{
  services.spotifyd = {
    enable = true;
    config = ''
      [global]
      username = ${secrets.mopidy.spotify.username}
      password = ${secrets.mopidy.spotify.password}

      backend = pulseaudio

      device_name = toiler

      bitrate = 320

      volume_normalisation = true
      normalisation_pregain = -10

      device_type = stb

      zeroconf_port = 4444
    '';
  };

  # HACK: the provided service uses a dynamic user which can not authenticate to the pulse daemon
  # This is mitigated by using a static user
  users.users.spotifyd = {
    group = "audio";
    extraGroups = [ "audio" ];
    description = "spotifyd daemon user";
    home = "/var/lib/spotifyd";
    isSystemUser = true;
  };

  systemd.services.spotifyd = {
    serviceConfig.User = "spotifyd";

    serviceConfig.DynamicUser = mkForce false;
    serviceConfig.SupplementaryGroups = mkForce [ ];
  };
  # End of hack...

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      spotify = between [ "established" ] [ "drop" ] [
        ''
          ip saddr 172.23.200.0/24
          tcp dport 4444
          accept
        ''
        ''
          ip saddr 172.23.200.0/24
          udp dport 5353
          accept
        ''
      ];
    };
  };
}
