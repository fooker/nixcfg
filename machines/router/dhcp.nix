{ lib, device, ... }:

with lib;

let
  # All DHCP reservations by IP version from all prefixes over all interfaces
  reservations = concatMap
    (interface: concatMap
      (address: concatMap
        (reservation: optional (address.address.version == 4 && reservation.dhcp.enable) {
          inherit interface;
          inherit address;

          inherit (address.prefix) prefix;

          first = elemAt reservation.range 0;
          last = elemAt reservation.range 1;

          config = reservation.dhcp;
        })
        (attrValues address.prefix.reservations))
      (interface.addresses))
    (attrValues device.interfaces);

  # All interfaces that have at least one prefix with a DHCP reservation
  interfaces = attrNames (groupBy
    (reservation: reservation.interface.name)
    reservations);

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
          (reservation: {
            "subnet" = toString reservation.prefix;
            "interface" = reservation.interface.name;

            "option-data" = [
              {
                "name" = "routers";
                "data" = "${toString reservation.address.address}";
              }
              {
                "name" = "domain-name-servers";
                "data" = "${toString reservation.address.address}";
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
                "data" = "${toString reservation.address.address}";
              }
            ];

            "pools" = [
              {
                "pool" = "${toString reservation.first}-${toString reservation.last}";
              }
            ];
          } // (optionalAttrs (reservation.config.valid-lifetime != null) {
            inherit (reservation.config) valid-lifetime;
          }))
          reservations;
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
}
