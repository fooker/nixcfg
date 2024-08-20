{ lib, name, config, inputs, ... }:

with lib;

let
  network = (inputs.ipam.eval [
    ./../network
    {
      inherit (config.ipam) extends;
    }
  ]).config;

  device = network.devices."${name}";

in
{
  options = {
    ipam.extends = mkOption {
      type = types.attrsOf (types.attrsOf types.raw);
      description = ''
        Extension modules for IPAM declarations.
      '';
      default = { };
    };
  };

  config = {
    # Expose device and network config to other modules
    _module.args = {
      inherit network device;
    };

    # Add a tag fir the side the device is located in
    deployment.tags = optional (device.site != null) "site-${device.site.name}";

    ipam.extends = {
      reservation.dhcp = {
        type = types.nullOr (types.submodule ({ name, ... }: {
          options = {
            enable = mkEnableOption "DHCP Pool";

            valid-lifetime = mkOption {
              type = types.nullOr types.ints.positive;
              description = ''
                The lifetime of a DHCP lease.
              '';
              default = null;
            };
          };
        }));
        description = ''
          DHCP reservations
        '';
        default = { };
      };

      interface.dhcp = {
        type = types.attrs;
        description = ''
          Interface specific DHCP option data
        '';
        default = { };
      };
    };
  };
}
