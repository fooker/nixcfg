{ config, lib, ... }:

with lib;
{
  options.web.reverse-proxy = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        domains = mkOption {
          type = types.nonEmptyListOf types.str;
          description = "Domains to proxy for";
        };

        target = mkOption {
          type = types.str;
          description = "Target to pass requests to";
        };

        extraConfig = mkOption {
          type = types.lines;
          default = "";
          description = "Additional config for the app";
        };
      };
    });

    description = "Virtual reverse proxy hosts";
    default = { };
  };

  config.web.apps = mapAttrs
    (_: app: {
      inherit (app) domains;

      config = {
        locations."/" = {
          proxyPass = app.target;
          proxyWebsockets = true;

          inherit (app) extraConfig;
        };
      };
    })
    config.web.reverse-proxy;
}
