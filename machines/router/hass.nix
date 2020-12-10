args @ { config, lib, pkgs, ... }:

{
  services.mosquitto = {
    enable = true;

    host = "0.0.0.0";
    port = 1883;

    allowAnonymous = true;
    
    # TODO: Use real ACLs (with patterns and users) here
    aclExtraConf = ''
      topic readwrite #
    '';

    users = {};

    extraConf = ''
      persistence true

      autosave_interval 10
      autosave_on_changes false
    '';
  };

  services.home-assistant = {
    enable = true;
    port = 8123;

    config = import ./hass args;

    autoExtraComponents = true;

    package = pkgs.unstable.home-assistant.override {
      # Disable tests for spotipy as test library is missing
      packageOverrides = self: super: {
        spotipy = super.spotipy.overrideAttrs (_: {
          doCkeck = false;
          doInstallCheck = false;
        });
      };

      extraPackages = ps: with ps; [
        # Reauired vor Denon AVR integration
        pythonPackages.denonavr

        # Required for zeroconf
        pythonPackages.getmac
      ];
    };
  };

  letsencrypt.production = true;
  letsencrypt.certs.hass = {
    domains = [ "hass.home.open-desk.net" ];
    owner = "nginx";
    trigger = "${pkgs.systemd}/bin/systemctl reload nginx.service";
  };

  reverse-proxy = {
    enable = true;
    hosts = {
      "hass" = {
        domains = [ "hass.home.open-desk.net" ];
        target = "http://[::1]:8123/";
      };
    };
  };

  services.nginx = {
    virtualHosts = {
      "deploy" = {
        serverName = "deploy.home.open-desk.net";
        serverAliases = [ "deploy" ];
        listen = [
          { addr = "192.168.0.1"; port = 80; }
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
      mqtt = between ["established"] ["drop"] ''
        meta iifname iot
        tcp
        dport 1883
        accept
      '';
    };
  };

  backup.paths = [
    config.services.home-assistant.configDir
    config.services.mosquitto.dataDir
  ];
}
