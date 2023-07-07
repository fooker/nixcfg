{ config, pkgs, lib, inputs, device, ... }:

{
  services.mosquitto = {
    enable = true;

    listeners = [
      {
        port = 1883;

        omitPasswordAuth = true;

        # TODO: Use real ACLs (with patterns and users) here
        settings.allow_anonymous = true;
        acl = [
          "topic readwrite #"
        ];

        users = { };
      }
    ];

    settings = {
      "autosave_interval" = 10;
      "autosave_on_changes" = false;
    };
  };

  services.home-assistant = {
    enable = true;

    config = import ./hass { inherit lib; };

    # package = pkgs.unstable.home-assistant;

    extraComponents = [
      "default_config"
      "lovelace"
      "mqtt"
      "esphome"
      "denonavr"
      "ipp"
      "discovery"
      "mjpeg"
      "spotify"
      "media_player"
      "vacuum"
      "xiaomi_miio"
      "weather"
      "octoprint"
      "wled"
    ];
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ENV{ID_VENDOR_ID}=="10c4", ENV{ID_MODEL_ID}=="ea60", ENV{ID_SERIAL_SHORT}="00_12_4B_00_25_9A_E3_4A", SYMLINK+="zigbee"
  '';

  systemd.tmpfiles.rules = [
    "C /var/lib/hass/custom_components/solarman - - - - ${inputs.hass-solarman}/custom_components/solarman"
    "Z /var/lib/hass/custom_components 770 hass hass - -"
  ];

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      permit_join = false;

      frontend = {
        port = 8034;
        host = "::1";
        url = "https://zigbee.home.open-desk.net";
      };

      homeassistant = true;
      availability = true;

      serial = {
        port = "/dev/zigbee";
      };

      mqtt = {
        server = "mqtt://localhost:1883";
        base_topic = "frisch/home/zigbee";
        client_id = "zigbee2mqtt";
      };
    };
  };

  web.reverse-proxy = {
    "hass" = {
      domains = [ "hass.home.open-desk.net" ];
      target = "http://[::1]:8123/";
    };
    "zigbee" = {
      domains = [ "zigbee.home.open-desk.net" ];
      target = "http://[::1]:8034";
    };
  };

  services.nginx = {
    virtualHosts = {
      "deploy" = {
        serverName = "deploy.home.open-desk.net";
        serverAliases = [ "deploy" ];
        listen = [
          { addr = toString device.interfaces.iot.address.ipv4.address; port = 80; }
        ];
        root = "/srv/http/deploy";
      };
    };
  };

  systemd.services.esper-heartbeat = {
    after = [ "network.target" "mosquitto.service" ];
    requires = [ "mosquitto.service" ];
    description = "ESPer heartbeat";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''${pkgs.mosquitto}/bin/mosquitto_pub \
        -i 'esper-heartbeat' \
        -h localhost \
        -t 'frisch/home/esper/heartbeat' \
        -n \
      '';
    };
  };

  systemd.timers.esper-heartbeat = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "mosquitto.service" ];
    requires = [ "mosquitto.service" ];
    description = "ESPer heartbeat";
    timerConfig = {
      OnCalendar = "minutely";
      Unit = "esper-heartbeat.service";
    };
  };

  environment.systemPackages = with pkgs; [ mosquitto ];

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      mqtt = between [ "established" ] [ "drop" ] ''
        meta iifname {iot, priv}
        tcp dport 1883
        accept
      '';
    };
  };

  dns.zones = {
    net.open-desk.home.iot = {
      mqtt = { A = device.interfaces.iot.address.ipv4.address; };
      deploy = { A = device.interfaces.iot.address.ipv4.address; };
    };
  };

  backup.paths = [
    config.services.home-assistant.configDir
    config.services.mosquitto.dataDir
    config.services.zigbee2mqtt.dataDir
  ];
}
