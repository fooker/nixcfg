{ config, pkgs, device, ... }:

{
  services.mosquitto = {
    enable = true;

    listeners = [
      {
        address = "0.0.0.0";
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
    port = 8123;

    config = import ./hass;
  };

  web.reverse-proxy = {
    "hass" = {
      domains = [ "hass.home.open-desk.net" ];
      target = "http://[::1]:8123/";
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
  ];
}
