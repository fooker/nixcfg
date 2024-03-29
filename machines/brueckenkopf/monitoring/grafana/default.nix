{ config, ... }:

{
  services.grafana = {
    enable = true;
    settings = {
      server.domain = "stats.open-desk.net";
      server.http_addr = "127.0.0.1";

      security.adminUser = "root";
      security.adminPassword = "$__file{${config.sops.secrets."grafana/adminPassword".path}}";
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

  sops.secrets."grafana/adminPassword" = {
    owner = "grafana";
  };
}
