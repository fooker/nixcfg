{ config, lib, pkgs, ... }:

with lib;
{
  options.reverse-proxy = {
    hosts = mkOption {
      type = types.attrsOf (types.submodule ({
        options = {
          domains = mkOption {
            type = types.nonEmptyListOf types.str;
            description = "Domains to proxy for";
          };

          target = mkOption {
            type = types.str;
            description = "Target to pass requests to";
          };
        };
      }));

      description = "Virtual reverse proxy hosts";
      default = { };
    };
  };

  config = mkIf (config.reverse-proxy.hosts != { }) {
    letsencrypt.certs = mapAttrs
      (_: host: {
        domains = host.domains;
        owner = "nginx";
        trigger = "${pkgs.systemd}/bin/systemctl reload nginx.service";
      })
      config.reverse-proxy.hosts;

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = mapAttrs
        (name: host: {
          serverName = head host.domains;
          serverAliases = tail host.domains;

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

          locations."/" = {
            proxyPass = host.target;
            proxyWebsockets = true;

            # Workaround for https://github.com/NixOS/nixpkgs/pull/100708
            extraConfig = ''
              proxy_set_header Accept-Encoding "$http_accept_encoding";
            '';
          };

          extraConfig = ''
            add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload;";
          '';
        })
        config.reverse-proxy.hosts;
    };

    dns.zones =
      let
        domains = concatMap
          (host: host.domains)
          (attrValues config.reverse-proxy.hosts);
      in
      mkMerge (map
        (domain: (mkDomainAbsolute domain).mkRecords {
          A = config.dns.host.ipv4;
          AAAA = config.dns.host.ipv6;
        })
        domains);

    firewall.rules = dag: with dag; {
      inet.filter.input = {
        reverse-proxy = between [ "established" ] [ "drop" ] ''
          tcp dport { 80, 443 }
          accept
        '';
      };
    };
  };
}
