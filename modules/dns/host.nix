{ config, lib, id, device, ... }:

with lib;

{
  options = {
    dns.host = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          zone = mkOption {
            type = types.domain.absolute;
            description = "The zone the host is exposted to";
            default = mkDomainAbsolute "open-desk.net";
          };

          realm = mkOption {
            type = types.domain.relative;
            description = "The realm in the zone the host is exposted to";
            default = mkDomainRelative [ ];
          };

          name = mkOption {
            type = types.domain.relative;
            description = "The host name to expose";
            default = mkDomainRelative id;
          };

          domain = mkOption {
            type = types.domain.absolute;
            description = "The full qualified domain of the exposed host";
            readOnly = true;
          };

          interface = mkOption {
            type = types.refAttr device.interfaces;
            description = "Interface to take host IPs from";
            readOnly = true;
          };

          ipv4 = mkOption {
            type = types.ip.address.v4;
            description = "IPv4 address of the host";
            readOnly = true;
            default = config.dns.host.interface.address.ipv4.address;
          };

          ipv6 = mkOption {
            type = types.ip.address.v6;
            description = "IPv6 address of the host";
            readOnly = true;
            default = config.dns.host.interface.address.ipv6.address;
          };
        };

        config = {
          domain = foldl (domain: domain.resolve) config.dns.host.zone [
            config.dns.host.realm
            (mkDomainRelative "dev")
            config.dns.host.name
          ];
        };
      });
      default = null;
    };
  };

  config = {
    dns.zones = mkIf (config.dns.host != null) (config.dns.host.domain.mkRecords {
      A = config.dns.host.ipv4;
      AAAA = config.dns.host.ipv6;
    });
  };
}
