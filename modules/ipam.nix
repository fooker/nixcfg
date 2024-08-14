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
  };
}
