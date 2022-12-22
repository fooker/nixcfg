{ config, ... }:

let
  secrets = import ../../secrets.nix;
in
{
  services.grafana = {
    enable = true;
    settings = {
      server.domain = "stats.open-desk.net";

      security.adminUser = "root";
      security.adminPassword = secrets.grafana.adminPassword;
    };
  };

  web.reverse-proxy = {
    "grafana" = {
      domains = [ config.services.grafana.settings.server.domain ];
      target = with config.services.grafana.settings.server; "http://${http_addr}:${toString http_port}";
    };
  };

  backup.paths = [
    config.services.grafana.dataDir
  ];
}
