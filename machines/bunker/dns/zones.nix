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
    };

    org.open-desk = zone // {};
    
    cloud.frisch = zone // {
      MX = {
        preference = 0;
        exchange = "mail.svc.open-desk.net.";
      };
    };

    sh.lab = zone // {};
    
    org.schoen-und-gut = zone // {};
    
    io.adacta = zone // {};

    jetzt.ak36 = zone // {};
  };
}