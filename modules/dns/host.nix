{ config, lib, id, ... }:

with lib;

{
  options = {
    dns.host = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          zone = mkOption {
            type = types.listOf types.str;
            description = "The zone the host is exposted to";
            default = [ "net" "open-desk" ];
          };

          realm = mkOption {
            type = types.either types.str (types.listOf types.str);
            description = "The realm in the zone the host is exposted to";
            default = [];
            apply = toList;
          };

          name = mkOption {
            type = types.listOf types.str;
            description = "The host name to exposte";
            default = id;
          };

          domain = mkOption {
            type = types.listOf types.str;
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
          domain = concatLists [
            config.dns.host.zone
            config.dns.host.realm
            [ "dev" ]
            config.dns.host.name
          ];
        };
      });
      default = null;
    };
  };

  config = {
    dns.zones = mkIf (config.dns.host != null) (setAttrByPath (config.dns.host.domain) {
      A = config.dns.host.ipv4;
      AAAA = config.dns.host.ipv6;
    });
  };
}