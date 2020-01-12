{ config, lib, pkgs, ... }:

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
  };

  services.home-assistant = {
    enable = true;
    port = 8123;

    package = pkgs.home-assistant.override {
      extraPackages = ps: with ps; [
        ps.pythonPackages.paho-mqtt
      ];
    };
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
        locations."/" = {
          proxyPass = "http://127.0.0.1:8123/";
          proxyWebsockets = true;
        };
      };
    };

  };

  environment.systemPackages = [ pkgs.mosquitto ];

  networking.firewall.interfaces = {
    "priv" = {
      allowedTCPPorts = [ 80 443 ];
    };
    "iot" = {
      allowedTCPPorts = [ 1883 ];
    };
  };
}
