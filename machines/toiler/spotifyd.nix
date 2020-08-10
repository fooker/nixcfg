{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;

in {
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
  };

  systemd.services.spotifyd = {
    serviceConfig.User = "spotifyd";

    serviceConfig.DynamicUser = lib.mkForce false;
    serviceConfig.SupplementaryGroups = lib.mkForce [];
  };
  # End of hack...

  networking.firewall.interfaces = {
    "priv" = {
      allowedUDPPorts = [ 5353 ];
      allowedTCPPorts = [ 4444 ];
    };
  };
}