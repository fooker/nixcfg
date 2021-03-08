{ config, lib, ext, id, ... }:

with lib;
with ext;

{
  options = {
    dns.host = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          zone = mkOption {
            type = types.domain.absolute;
            description = "The zone the host is exposted to";
            default = domain.absolute "open-desk.net";
          };

          realm = mkOption {
            type = types.domain.relative;
            description = "The realm in the zone the host is exposted to";
            default = domain.relative [];
          };

          name = mkOption {
            type = types.domain.relative;
            description = "The host name to expose";
            default = domain.relative id;
          };

          domain = mkOption {
            type = types.domain.absolute;
            description = "The full qualified domain of the exposed host";
            readOnly = true;
          };

          ipv4 = mkOption {
            type = types.str;
            description = "IPv4 address of the host";
          };

          ipv6 = mkOption {
            type = types.str;
            description = "IPv6 address of the host";
          };
        };

        config = {
          domain = foldl (domain: domain.resolve) config.dns.host.zone [
            config.dns.host.realm
            (domain.relative "dev")
            config.dns.host.name
          ];
        };
      });
      default = null;
    };
  };

  config = {
    dns.zones = mkIf (config.dns.host != null) (config.dns.host.domain.mkZone {
      A = config.dns.host.ipv4;
      AAAA = config.dns.host.ipv6;
    });
  };
}