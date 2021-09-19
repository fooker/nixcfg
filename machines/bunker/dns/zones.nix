{ lib, network, ... }:

with lib;

{
  dns.zones =
    let
      nameservers = [
        "ns.inwx.de."
        "ns2.inwx.de."
        "ns3.inwx.de."
      ];

      zone = {
        SOA = {
          mname = "ns.inwx.de.";
          rname = "hostmaster";
        };

        NS = nameservers;

        # Prohibit creation of certificates by default
        CAA = [
          {
            critical = true;
            tag = "issue";
            value = ";";
          }
          {
            critical = true;
            tag = "issueWild";
            value = ";";
          }
          {
            critical = true;
            tag = "iodef";
            value = "mailto:hostmaster@open-desk.net";
          }
        ];
      };
    in
    {
      net.open-desk = zone // {

        # Dynamic updated zone for ACME
        dyn = {
          ttl = 60;

          SOA = {
            mname = "ns.inwx.de.";
            rname = "hostmaster";
            refresh = 200;
            retry = 300;
            expire = 1209600;
            minimum = 300;
          };

          NS = nameservers;

          parent = {
            NS = nameservers;
          };
        };

        # Legacy host records
        home.dev = {
          "amp" = {
            A = network.devices."amp".interfaces."priv".address.ipv4.address;
          };
          "printer" = {
            A = network.devices."printer".interfaces."priv".address.ipv4.address;
          };
        };

        # Other legacy records
        magnetico = { CNAME = "fliegerhorst.dev.open-desk.net."; };
      };

      org.open-desk = zone;

      cloud.frisch = zone;

      sh.lab = zone;

      org.schoen-und-gut = zone;

      io.adacta = zone;

      jetzt.ak36 = zone;
    };
}
