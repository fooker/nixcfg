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

  nixpkgs.overlays = [ (self: super: {

  }) ];

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

  services.nginx = {
    enable = true;
    
    resolver.addresses = [ "[::1]" ];

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "hass" = {
        serverName = "hass.home.open-desk.net";
        serverAliases = [ "hass" ];

        listen = [
          { addr = "172.23.200.129"; port = 80; }
          { addr = "172.23.200.129"; port = 443; ssl = true; }
        ];

        forceSSL = true;
        sslCertificate = config.letsencrypt.certs.hass.path.cert;
        sslCertificateKey = config.letsencrypt.certs.hass.path.key;

        locations."/" = {
          proxyPass = "http://[::1]:8123/";
          proxyWebsockets = true;
        };
      };

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

  networking.firewall.interfaces = {
    "priv" = {
      allowedTCPPorts = [ 80 443 ];
    };
    "iot" = {
      allowedTCPPorts = [ 80 1883 ];
    };
  };

  backup.paths = [
    config.services.home-assistant.configDir
    config.services.mosquitto.dataDir
  ];
}
