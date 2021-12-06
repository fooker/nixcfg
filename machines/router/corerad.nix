{ lib, device, ... }:

with lib;

let
  # All interfaces that have at least one ipv6 address assigned
  interfaces = attrNames (filterAttrs
    (_: interface: any
      (address: address.address.version == 6)
      interface.addresses)
    device.interfaces);

in
{
  services.corerad = {
    enable = true;
    settings = {
      interfaces = [
        {
          names = interfaces;

          advertise = true;

          managed = false;
          other_config = false;

          rdnss = [{
            servers = [ "::" ];
          }];

          dnssl = [{
            domain_names = [ "home.open-desk.net" ];
          }];

          prefix = [
            {
              prefix = "::/64";
            }
          ];
        }
      ];
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      ra = between [ "established" ] [ "drop" ] ''
        ip6 nexthdr icmpv6
        icmpv6 type {
          nd-router-solicit,
          nd-router-advert,
        }
        accept
      '';
    };
  };
}
