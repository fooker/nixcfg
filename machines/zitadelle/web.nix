{ config, lib, pkgs, ... }:

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
  };
in {
  dns.zones = let
    # All domains that we serve for
    domains = concatMap
      (app: map (domain: reverseList (splitString "." domain)) app.domains)
      (attrValues apps);
  in mkMerge (map
    (domain: setAttrByPath domain {
      A = config.hive.self.address.ipv4;
      AAAA = config.hive.self.address.ipv6;
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
      reverse-proxy = between ["established"] ["drop"] ''
        tcp
        dport { 80, 443 }
        accept
      '';
    };
  };
}