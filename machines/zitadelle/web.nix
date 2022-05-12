{ config, lib, pkgs, inputs, ... }:

with lib;

let
  apps = {
    "box" = {
      domains = [ "box.open-desk.net" "frisch.cloud" "www.frisch.cloud" ];
    };

    "blog" = {
      domains = [ "open-desk.org" "www.open-desk.org" ];
      root = pkgs.callPackage inputs.blog { };
    };

    "schoen-und-gut" =
      let
        php = pkgs.php.buildEnv { };
        site = pkgs.applyPatches {
          name = "schoen-und-gut-patched";
          src = inputs.schoen-und-gut;
          postPatch = ''
            sed -i '1s;^;#!${ php }/bin/php-cgi\n;' ./mail.php
          '';
        };
      in
      {
        domains = [ "schoen-und-gut.org" "www.schoen-und-gut.org" ];
        root = site;

        config = {
          locations."/mail.php" = {
            extraConfig = ''
              include ${pkgs.nginx}/conf/fastcgi.conf;
              include ${pkgs.nginx}/conf/fastcgi_params;

              fastcgi_pass unix:${config.services.fcgiwrap.socketAddress};
            '';
          };
        };
      };
  };

in
{
  dns.zones =
    let
      # All domains that we serve for
      domains = concatMap
        (app: app.domains)
        (attrValues apps);
    in
    mkMerge (map
      (domain: (mkDomainAbsolute domain).mkRecords {
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

    virtualHosts = mapAttrs
      (name: app: mkMerge [
        {
          serverName = head app.domains;
          serverAliases = tail app.domains;

          listen = [
            { addr = "0.0.0.0"; port = 80; }
            { addr = "[::]"; port = 80; }
            { addr = "0.0.0.0"; port = 443; ssl = true; }
            { addr = "[::]"; port = 443; ssl = true; }
          ];

          forceSSL = true;
          sslCertificate = config.letsencrypt.certs."${name}".path.cert;
          sslCertificateKey = config.letsencrypt.certs."${name}".path.key;
          sslTrustedCertificate = config.letsencrypt.certs."${name}".path.fullchain;

          root = app.root or "/srv/http/${name}";

          extraConfig = ''
            default_type application/octet-stream;
            add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload;";
          '';
        }
        (app.config or { })
      ])
      apps;
  };

  services.fcgiwrap = {
    enable = true;
    user = config.services.nginx.user;
  };

  systemd.services."nginx" = {
    unitConfig = {
      RequiresMountsFor = [ "/srv/http" ];
    };
  };

  letsencrypt.certs = mapAttrs
    (_: app: {
      domains = app.domains;
      owner = "nginx";
      trigger = "${pkgs.systemd}/bin/systemctl reload nginx.service";
    })
    apps;

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      web = between [ "established" ] [ "drop" ] ''
        tcp dport { 80, 443 }
        accept
      '';
    };
  };

  monitoring.services = flatten (mapAttrsToList
    (_: app: map
      (domain: [
        {
          name = "HTTP:${domain}";
          interfaces = "ext";
        }
        {
          name = "HTTPS:${domain}";
          interfaces = "ext";
        }
      ])
      app.domains)
    apps);
}
