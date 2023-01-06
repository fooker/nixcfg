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

            DS = [
              {
                keyTag = 58674;
                algorithm = "ED25519";
                digestType = "SHA-256";
                digest = "d9714dcee6b66460e4bbab62201728d5b488b94d423b4b31c9bc71724176c992";
              }
              {
                keyTag = 58674;
                algorithm = "ED25519";
                digestType = "SHA-384";
                digest = "8c27502f7f35d7c2e20523776f6a29bbc59b29633786b3f406061e5dc24de290f5577ba575248b7d22451d14d8a29b66";
              }
            ];
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
