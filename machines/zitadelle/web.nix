{ config, lib, ext, pkgs, ... }:

with lib;

let
  sources = import ../../nix/sources.nix;
  apps = {
    "box" = {
      domains = [ "box.open-desk.net" "frisch.cloud" "www.frisch.cloud" ];
    };
    "blog" = {
      domains = [ "open-desk.org" "www.open-desk.org" ];
      root = pkgs.callPackage sources.blog {};
    };
    "schoen-und-gut" = {
      domains = [ "schoen-und-gut.org" "www.schoen-und-gut.org" ];
      root = sources.schoen-und-gut;
    };
  };
in {
  dns.zones = let
    # All domains that we serve for
    domains = concatMap
      (app: app.domains)
      (attrValues apps);
  in mkMerge (map
    (domain: (ext.domain.absolute domain).mkZone {
      A = config.dns.host.ipv4;
      AAAA = config.dns.host.ipv6;
    })
    domains);

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

        root = app.root or "/srv/http/${name}";
        
        extraConfig = ''
          default_type application/octet-stream;
        '';
      }) apps;
   };

   letsencrypt.certs = mapAttrs (name: app: {
      domains = app.domains;
      owner = "nginx";
      trigger = "${pkgs.systemd}/bin/systemctl reload nginx.service";
    }) apps;

   firewall.rules = dag: with dag; {
    inet.filter.input = {
      web = between ["established"] ["drop"] ''
        tcp
        dport { 80, 443 }
        accept
      '';
    };
  };
}