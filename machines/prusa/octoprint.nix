{ config, lib, pkgs, sources, machine, ... }:

let
  pkgs-unstable = import sources.nixpkgs-unstable {
    system = machine.system;
  };
in {
  nixpkgs.overlays = [
    (self: super: {
      octoprint = pkgs-unstable.octoprint;
      # mjpg-streamer = super.mjpg-streamer.override {};
    })
  ];

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
  };

  services.mjpg-streamer = {
    enable = true;
    # inputPlugin = "input_raspicam.so -x 1280 -y 720 -fps 25 -ex antishake -vs -ev";
    inputPlugin = "input_uvc.so --fps 25 --resolution 1280x720";
    outputPlugin = "output_http.so -p 5050 -n -w @www@";
  };

  services.nginx = {
    enable = true;
    
    package = pkgs.nginx.override {
      modules = with pkgs.nginxModules; [ rtmp ];
    };

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
        };

        "/webcam/" = {
          proxyPass = "http://localhost:5050/";
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
