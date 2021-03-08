{ lib, ...}: 

with lib;

{
  dns.zones = let
    zone = {
      SOA = {
        mname = "ns.inwx.de.";
        rname = "hostmaster";
      };

      NS = [
        "ns.inwx.de."
        "ns2.inwx.de."
        "ns3.inwx.de."
      ];
    };

    hive = {
      A = [ "37.120.172.177" "37.120.172.185" ];
      AAAA = [ "2a03:4000:6:701d::" "2a03:4000:6:701e::" ];
    };
  in {
    net.open-desk = zone // {

      # Dynamic updated zone for ACME
      dyn = {
        ttl = 60;

        SOA = {
          mname = "ns.inwx.de.";
          rname = "hostmaster";
          refresh = 200;
          retry = 300;
          expire = 1814400;
          minimum = 300;
        };
        
        NS = [
          "ns.inwx.de."
          "ns2.inwx.de."
          "ns3.inwx.de."
        ];
      };

      # Legacy host records
      dev = {
        "zitadelle"."bak" = {
          A = "37.221.196.84";
        };
        "brueckenkopf" = {
          A = "193.174.29.6";
          AAAA = "2001:638:301:11a3::6";
        };
        "fliegerhorst" = {
          A = "193.34.144.95";
          AAAA = "2a02:c205:3002:2452::1";
        };
        "raketensilo" = {
          AAAA = "2001:638:301:11a3::64";
        };
      };

      # Legacy host records
      home.dev = {
        "amp" = {
          A = "172.23.200.133";
        };
        "printer" = {
          A = "172.23.200.160";
        };
      };

      # Other legacy records
      aurblobs = { CNAME = "brueckenkopf.dev.open-desk.net."; };
    };

    org.open-desk = zone // {};
    
    cloud.frisch = zone // {};

    sh.lab = zone // {};
    
    org.schoen-und-gut = zone // {};
    
    io.adacta = zone // {};

    jetzt.ak36 = zone // {};
  };
}