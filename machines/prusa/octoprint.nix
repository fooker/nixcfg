{ config, lib, pkgs, ... }:

{
  services.octoprint = {
    enable = true;
    host = "localhost";

    plugins = [
    ];

    extraConfig = {
      slicing = {
        enabled = false;
      };

      serial = {
        port = "/dev/ttyACM0";
        baudrate = 115200;
        autoconnect = true;
      };
    };
  };

  services.nginx = {
    enable = true;
    
    resolver.addresses = [ "[::1]" ];

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts.default = {
      default = true;

      listen = [{
        addr = "0.0.0.0";
        port = 80;
        ssl = false;
      }];

      locations = {
        "/" = {
          proxyPass = "http://localhost:5000";
          proxyWebsockets = true;
        };
      };
    };
  };

  services.avahi = {
    enable = true;
  };

  networking.firewall.interfaces = {
    "priv" = {
      allowedTCPPorts = [ 80 443 ];
    };
  };

  users.users.octoprint = {
    extraGroups = [ "dialout" ];
  };
}
