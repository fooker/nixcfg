{ config, lib, pkgs, ... }:

with lib;

let
  nameserver = "bunker.dev.open-desk.net";
  tsigAlgorithm = "hmac-sha512.";
  tsigKey = "acme_update";
in {
  options = {
    letsencrypt = {
      production = mkOption {
        type = types.bool;
        default = false;
      };

      certs = mkOption {
        type = types.attrsOf (types.submodule ({ name, ... }: {
          options = {
            domains = mkOption {
              type = types.listOf types.str;
            };

            owner = mkOption {
              type = types.str;
              default = "root";
            };

            trigger = mkOption {
              type = types.lines;
            };

            path = {
              cert = mkOption {
                type = types.path;
              };
              chain = mkOption {
                type = types.path;
              };
              fullchain = mkOption {
                type = types.path;
              };
              full = mkOption {
                type = types.path;
              };
              key = mkOption {
                type = types.path;
              };
            };
          };

          config = {
            path = let 
              dir = config.security.acme.certs."${name}".directory;
            in {
              cert = "${dir}/cert.pem";
              chain = "${dir}/chain.pem";
              fullchain = "${dir}/fullchain.pem";
              full = "${dir}/full.pem";
              key = "${dir}/key.pem";
            };
          };
        }));
        default = {};
      };
    };
  };

  config = mkIf (config.letsencrypt.certs != {}) {
    security.acme = {
      email = "hostmaster@open-desk.net";
      acceptTerms = true;

      server = mkIf (!config.letsencrypt.production) "https://acme-staging-v02.api.letsencrypt.org/directory";

      certs = mapAttrs (name: cert: {
        domain = head cert.domains;
        extraDomains = listToAttrs (map (domain: nameValuePair domain null) (tail cert.domains));
        
        dnsProvider = "rfc2136";
        credentialsFile = pkgs.writeText "acme-credentials" ''
          LEGO_EXPERIMENTAL_CNAME_SUPPORT=true
          RFC2136_NAMESERVER=${nameserver}
          RFC2136_TSIG_ALGORITHM=${tsigAlgorithm}
          RFC2136_TSIG_KEY=${tsigKey}
          RFC2136_TSIG_SECRET_FILE=/var/lib/acme/update.tsig
          RFC2136_PROPAGATION_TIMEOUT=3600
        '';

        group = cert.owner;
        allowKeysForGroup = true;
        
        postRun = cert.trigger; 
      }) config.letsencrypt.certs;
    };

    deployment.secrets = {
      "acme-update-tsig-secret" = {
        source = toString ../secrets/acme_update.tsig;
        destination = "/var/lib/acme/update.tsig";
        owner.user = "root";
        owner.group = "root";
      };
    };
  };
}