{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./reverse-proxy.nix
  ];

  options.web.apps = mkOption {
    type = types.attrsOf (types.submodule ({
      options = {
        domains = mkOption {
          type = types.nonEmptyListOf types.str;
          description = ''
            Domains to serve
          '';
        };

        root = mkOption {
          type = types.path;
          description = ''
            Path of the web root
          '';
          default = "/var/empty/";
        };

        config = mkOption {
          type = types.unspecified;
          description = ''
            nginx config of the app
          '';
          default = { };
        };
      };
    }));

    description = ''
      Virtual web application host
    '';

    default = { };
  };

  config = mkIf (config.web.apps != { }) {
    services.nginx = {
      enable = true;

      package = pkgs.nginxQuic;

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

            http2 = true;
            http3 = true;

            root = mkDefault app.root;

            forceSSL = true;
            sslCertificate = config.letsencrypt.certs."${name}".path.cert;
            sslCertificateKey = config.letsencrypt.certs."${name}".path.key;
            sslTrustedCertificate = config.letsencrypt.certs."${name}".path.fullchain;

            extraConfig = ''
              add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload;";
            '';
          }
          app.config
        ])
        config.web.apps;
    };

    systemd.services."nginx" = {
      unitConfig = {
        RequiresMountsFor = mapAttrsToList
          (_: app: app.root)
          config.web.apps;
      };
    };

    dns.zones =
      let
        domains = concatMap
          (app: app.domains)
          (attrValues config.web.apps);
      in
      mkMerge (map
        (domain: (mkDomainAbsolute domain).mkRecords {
          A = config.dns.host.ipv4;
          AAAA = config.dns.host.ipv6;
        })
        domains);

    letsencrypt.certs = mapAttrs
      (_: app: {
        domains = app.domains;
        owner = "nginx";
        trigger = "${pkgs.systemd}/bin/systemctl reload nginx.service";
      })
      config.web.apps;

    firewall.rules = dag: with dag; {
      inet.filter.input = {
        webapp = between [ "established" ] [ "drop" ] [
          "tcp dport { 80, 443 } accept"
          "udp dport { 80, 443 } accept"
        ];
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
      config.web.apps);
  };
}
