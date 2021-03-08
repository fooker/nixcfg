{ config, lib, pkgs, machine, ... }:

{
  services.octoprint = {
    enable = true;
    host = "localhost";

    extraConfig = {
      slicing = {
        enabled = false;
      };

      serial = {
        port = "/dev/ttyACM0";
        baudrate = 115200;
        autoconnect = true;
      };

      webcam = {
        stream = "/webcam?action=stream";
        snapshot = "/webcam?action=snapshot";
      };
    };

    plugins = plugins: [
    ];
  };

  services.mjpg-streamer = {
    enable = true;
    inputPlugin = "input_uvc.so --fps 25 --resolution 1280x720 -rot 180";
    outputPlugin = "output_http.so -p 5050 -n -w @www@";
  };

  services.nginx = {
    enable = true;
    
    resolver.addresses = [ "[::1]" ];

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    clientMaxBodySize = "100m";

    virtualHosts.default = {
      default = true;

      listen = [{
        addr = "0.0.0.0";
        port = 80;
        ssl = false;
      }];

      locations = {
        "/" = {
          proxyPass = "http://localhost:5000/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Accept-Encoding "$http_accept_encoding";
          '';
        };

        "/webcam/" = {
          proxyPass = "http://localhost:5050/";
          
          # Workaround for https://github.com/NixOS/nixpkgs/pull/100708
          extraConfig = ''
            proxy_set_header Accept-Encoding "$http_accept_encoding";
          '';
        };
      };
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      octoprint = between ["established"] ["drop"] ''
        ip saddr 172.23.200.0/24
        tcp dport { 80, 443 }
        accept
      '';
    };
  };

  dns.zones = {
    net.open-desk.home.prusa = { CNAME = config.dns.host.domain; };
  };

  users.users.octoprint = {
    extraGroups = [ "dialout" ];
  };
}
