{ lib, config, device, ... }:

with lib;

{
  options.network = {
    enable = mkEnableOption "Network Configuration";

    ipam = mkEnableOption "Configuration through IPAM";

    interfaces = mkOption {
      type = types.attrsOf (types.coercedTo
        types.str
        (mac: { inherit mac; })
        (types.submodule ({ name, ... }: {
          options = {
            name = mkOption {
              type = types.str;
              description = ''
                Name of the interface.
              '';
              readOnly = true;
              default = name;
            };

            mac = mkOption {
              type = types.strMatching "^([0-9a-f]{2}:){5}([0-9a-f]{2})$";
              description = ''
                MAC address of the interface.
              '';
            };
          };
        })));
      description = ''
        Interfaces to manage.
      '';
      default = { };
    };
  };

  config = mkIf config.network.enable {
    network.interfaces = mkIf config.network.ipam (mapAttrs
      (_: interface: {
        inherit (interface) mac;
      })
      (filterAttrs
        (_: interface: interface.mac != null)
        device.interfaces));

    systemd.network = {
      enable = true;

      links = mapAttrs'
        (name: config: nameValuePair "00-${name}" {
          matchConfig = {
            MACAddress = config.mac;
            Type = "ether";
          };
          linkConfig = {
            Name = config.name;
          };
        })
        config.network.interfaces;

      networks = mkIf config.network.ipam (mapAttrs'
        (name: iface: nameValuePair "30-${name}" (
          let
            config =
              if iface.satelite != null
              then iface.satelite
              else {
                addresses = map
                  (addr: addr.withPrefix)
                  iface.addresses;
                gateways = map
                  (addr: addr.gateway)
                  (filter
                    (addr: addr.gateway != null && !(ip.address.equals addr.gateway addr.address))
                    iface.addresses);
                dns = unique (concatMap
                  (addr: addr.prefix.dns)
                  iface.addresses);
              };
          in
          {
            name = iface.name;

            address = map toString config.addresses;
            gateway = map toString config.gateways;
            dns = map toString config.dns;

            networkConfig = {
              IPv6AcceptRA = false;
            };
          }
        ))
        device.interfaces);
    };
  };
}
