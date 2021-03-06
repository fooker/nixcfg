{ config, lib, pkgs, path, ... }:

with lib;
{
  options.reverse-proxy = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    protected = mkOption {
      type = types.bool;
      default = false;
    };

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
      default = [];
    };
  };

  config = mkIf config.reverse-proxy.enable {
    letsencrypt.certs = mapAttrs (name: host: {
      domains = host.domains;
      owner = "nginx";
      trigger = "${pkgs.systemd}/bin/systemctl reload nginx.service";
    }) config.reverse-proxy.hosts;

    services.nginx = {
      enable = true;
      
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = mapAttrs (name: host: {
        serverName = head host.domains;
        serverAliases = tail host.domains;

        listen =
          let
            addr = "*";
          in [
            { inherit addr; port = 80; }
            { inherit addr; port = 443; ssl = true; }
          ];

        forceSSL = true;
        sslCertificate = config.letsencrypt.certs."${name}".path.cert;
        sslCertificateKey = config.letsencrypt.certs."${name}".path.key;

        locations."/" = {
          proxyPass = host.target;
          proxyWebsockets = true;

          # Workaround for https://github.com/NixOS/nixpkgs/pull/100708
          extraConfig = ''
            proxy_set_header Accept-Encoding "$http_accept_encoding";
          '';
        };
      }) config.reverse-proxy.hosts;
    };

    firewall.rules = dag: with dag; {
      inet.filter.input = {
        reverse-proxy = between ["established"] ["drop"] ''
          tcp
          dport { 80, 443 }
          accept
        '';
      };
    };
  };
}
