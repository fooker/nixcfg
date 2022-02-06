{ lib, device, ... }:

with lib;

let
  # All DHCP reservations by IP version from all prefixes over all interfaces
  reservations = concatMap
    (interface: concatMap
      (address: optional (hasAttr "dhcp" address.prefix.reservations) {
        inherit interface;
        inherit address;

        inherit (address.prefix) prefix;

        first = elemAt address.prefix.reservations."dhcp".range 0;
        last = elemAt address.prefix.reservations."dhcp".range 1;

        extraConfig = address.prefix.reservations."dhcp".extraConfig or { };
      })
      (filter
        (address: address.address.version == 4)
        interface.addresses))
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
          } // reservation.extraConfig)
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
