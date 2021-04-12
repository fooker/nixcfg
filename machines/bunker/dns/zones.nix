{ lib, ...}: 

with lib;

{
  dns.zones = let
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
          expire = 1209600;
          minimum = 300;
        };
        
        NS = nameservers;

        parent = {
          NS = nameservers;
        };
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
      grafana = { CNAME = "brueckenkopf.dev.open-desk.net."; };
      magnetico = { CNAME = "fliegerhorst.dev.open-desk.net."; };
      prometheus = { CNAME = "brueckenkopf.dev.open-desk.net."; };
      salt = { CNAME = "brueckenkopf.dev.open-desk.net."; };
      weechat = { CNAME = "brueckenkopf.dev.open-desk.net."; };
    };

    org.open-desk = zone // {};
    
    cloud.frisch = zone // {};

    sh.lab = zone // {};
    
    org.schoen-und-gut = zone // {};
    
    io.adacta = zone // {};

    jetzt.ak36 = zone // {};
  };
}