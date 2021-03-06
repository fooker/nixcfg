{ config, lib, pkgs, ... }:

with lib;

let
  apps = {
    "box" = {
      domains = [ "box.open-desk.net" ];
    };
    "blog" = {
      domains = [ "open-desk.org" ];
    };
  };
in {
   services.nginx = {
      enable = true;
      
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = mapAttrs (name: app: {
        serverName = head app.domains;
        serverAliases = tail app.domains;

        listen = [
          { addr = "*"; port = 80; }
          { addr = "*"; port = 443; ssl = true; }
        ];

        forceSSL = true;
        sslCertificate = config.letsencrypt.certs."${name}".path.cert;
        sslCertificateKey = config.letsencrypt.certs."${name}".path.key;

        root = "/srv/http/${name}";
      }) apps;
   };

   letsencrypt.certs = mapAttrs (name: app: {
      domains = app.domains;
      owner = "nginx";
      trigger = "${pkgs.systemd}/bin/systemctl reload nginx.service";
    }) apps;

   firewall.rules = dag: with dag; {
    inet.filter.input = {
      reverse-proxy = between ["established"] ["drop"] ''
        tcp
        dport { 80, 443 }
        accept
      '';
    };
  };
}