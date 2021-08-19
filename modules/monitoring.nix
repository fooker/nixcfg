{ lib, name, device, ... }:

with lib;

{
  options.monitoring = {
    label = mkOption {
      type = types.str;
      description = ''
        Label of this node.
      '';
      default = name;
    };

    id = mkOption {
      type = types.str;
      description = ''
        ID of this node.
      '';
      default = name;
    };

    services = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = ''
              The service name to monitor.
            '';
          };

          interfaces = mkOption {
            type = types.nullOr (
              types.coercedTo
                (types.enum (attrNames device.interfaces))
                singleton
                (types.listOf (types.enum (attrNames device.interfaces)))
            );
            description = ''
              The interfaces to monitor the service on.
            '';
          };
        };
      });
      description = ''
        Services to monitor.
      '';
      default = [ ];
    };
  };
}
