{ config, ... }:

let
  secrets = import ../../secrets.nix;
in
{
  services.grafana = {
    enable = true;
    domain = "stats.open-desk.net";

    security.adminUser = "root";
    security.adminPassword = secrets.grafana.adminPassword;
  };

  reverse-proxy.hosts = {
    "grafana" = {
      domains = [ config.services.grafana.domain ];
      target = "http://${ config.services.grafana.addr }:${ toString config.services.grafana.port }";
    };
  };

  backup.paths = [
    config.services.grafana.dataDir
  ];
}
