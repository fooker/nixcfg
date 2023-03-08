{ lib, device, ... }:

with lib;

let
  # All DHCP pool reservations by IP version from all prefixes over all interfaces
  pools = concatMap
    (interface: concatMap
      (address: concatMap
        (reservation: optional (address.address.version == 4 && reservation.dhcp.enable) {
          inherit interface;
          inherit address;

          first = elemAt reservation.range 0;
          last = elemAt reservation.range 1;

          config = reservation.dhcp;
        })
        (attrValues address.prefix.reservations))
      interface.addresses)
    (attrValues device.interfaces);

  # All interfaces that have at least one prefix with a DHCP pool reservation
  interfaces = attrNames (groupBy
    (reservation: reservation.interface.name)
    pools);

in
{
  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        "valid-lifetime" = 4000;
        "renew-timer" = 1000;
        "rebind-timer" = 2000;

        "interfaces-config" = {
          "interfaces" = interfaces;
        };

        "lease-database" = {
          "type" = "memfile";
          "persist" = true;
          "name" = "/var/lib/kea/dhcp4.leases";
        };

        "subnet4" = map
          (pool: {
            "subnet" = toString pool.address.prefix.prefix;
            "interface" = pool.interface.name;

            "option-data" = [
              {
                "name" = "routers";
                "data" = "${toString pool.address.address}";
              }
              {
                "name" = "domain-name-servers";
                "data" = "${toString pool.address.address}";
              }
              {
                "name" = "domain-name";
                "data" = "home.open-desk.net";
              }
              {
                "name" = "domain-search";
                "data" = "home.open-desk.net";
              }
              {
                "name" = "ntp-servers";
                "data" = "${toString pool.address.address}";
              }
            ];

            "pools" = [
              {
                "pool" = "${toString pool.first}-${toString pool.last}";
              }
            ];

            # Build a static reservation for all devices in the prefix of the defined pool
            "reservations" = concatMap
              (address: optional (address.interface.mac != null) {
                "hw-address" = address.interface.mac;
                "ip-address" = toString address.address;
              })
              (attrValues pool.address.prefix.addresses);
          } // (optionalAttrs (pool.config.valid-lifetime != null) {
            inherit (pool.config) valid-lifetime;
          }))
          pools;
      };
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      dhcp = between [ "established" ] [ "drop" ] ''
        meta iifname { ${concatStringsSep ", " interfaces} }
        udp sport bootpc
        udp dport bootps
        accept
      '';
    };
  };

  ipam.extends."reservation" = { name, ... }: {
    options = {
      dhcp = {
        enable = mkEnableOption "DHCP reservation";

        valid-lifetime = mkOption {
          type = types.nullOr types.ints.positive;
          description = ''
            The lifetime of a DHCP lease.
          '';
          default = null;
        };
      };
    };

    config = {
      dhcp.enable = mkDefault (name == "dhcp");
    };
  };
}
