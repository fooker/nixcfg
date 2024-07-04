{ lib, device, ... }:

with lib;

{
  options.monitoring = {
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

          meta = mkOption {
            type = types.attrsOf types.str;
            description = ''
              Metadata attributes for the service.
            '';
            default = { };
          };
        };
      });
      description = ''
        Services to monitor.
      '';
      default = [ ];
    };
  };

  config = {
    ipam.extends.device.monitoring = {
      type = types.submodule ({ name, ... }: {
        options = {
          id = mkOption {
            type = types.str;
            description = ''
              The foreign ID of the node.
              This must be kept constant over the whole livetime of the node.
            '';
            default = name;
          };
        };
      });
      description = ''
        Device specific monitoring settings.
      '';
    };

    ipam.extends.interface.monitoring = {
      type = types.submodule {
        options = {
          services = mkOption {
            type = types.listOf (types.coercedTo
              types.str
              (name: { inherit name; })
              (types.submodule {
                options = {
                  name = mkOption {
                    type = types.str;
                    description = ''
                      The service name to monitor.
                    '';
                  };

                  meta = mkOption {
                    type = types.attrsOf types.str;
                    description = ''
                      Metadata attributes for the service.
                    '';
                    default = { };
                  };
                };
              }));
            description = ''
              Services to monitor on that interface.
            '';
            default = [ ];
          };
        };
      };
      description = ''
        Interface specific monitoring options.
      '';
    };
  };
}
