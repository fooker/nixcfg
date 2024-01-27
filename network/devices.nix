{
  devices = {
    "notebook" = {
      type = "Lenovo Thinkpad T14 Gen1";
      role = "Notebook";
      site = null;
    };

    "router" = {
      type = "PC Engines APU.1C4";
      role = "Router";
      site = "home";

      interfaces = {
        "priv" = { };
        "guest" = { };
        "iot" = { };
        "mngt" = { };
      };
    };

    "nas" = {
      type = "QNAP TS-673";
      role = "NAS";
      site = "home";

      interfaces = {
        "priv" = { };
      };
    };

    "toiler" = {
      type = "Intel NUC6i5SYB";
      role = "Server";
      site = "home";

      interfaces = {
        "priv" = { };
        "iot" = { };
      };
    };

    "prusa" = {
      type = "Prusa MK4";
      role = "3D-Printer";
      site = "home";

      interfaces = {
        "priv" = {
          mac = "10:9c:70:29:58:bd";

          monitoring.services = [ "ICMP" ];
        };
      };
    };

    "schilderhaus" = {
      type = "Raspberry Pi 4";
      role = "Multimedia";
      site = "home";

      interfaces = {
        "priv" = {
          mac = "dc:a6:32:1d:d8:f8";
        };
      };
    };

    "amp" = {
      type = "Denon AVR-X3000";
      role = "Multimedia";
      site = "home";

      interfaces = {
        "priv" = {
          mac = "00:05:cd:38:94:8a";

          monitoring.services = [ "ICMP" ];
        };
      };
    };

    "photonic" = {
      type = "Raspberry Pi 3 Model B+";
      role = "Home Automation";
      site = "home";

      interfaces = {
        "priv" = {
          mac = "b8:27:eb:3e:05:3c";
        };
      };
    };

    "printer" = {
      type = "HP Color LaserJet MFP M281fdw";
      role = "2D-Printer";
      site = "home";

      interfaces = {
        "priv" = {
          mac = "f8:b4:6a:80:a2:cf";

          monitoring.services = [ "ICMP" "SNMP" ];
        };
      };
    };

    "modem" = {
      type = "DrayTek Vigor 130";
      role = "DSL Modem";
      site = "home";

      interfaces = {
        "mngt" = {
          mac = "00:1d:aa:87:58:ac";

          monitoring.services = [ "ICMP" "SNMP" ];
        };
      };
    };

    "br1" = {
      type = "Cisco SG 300-28P";
      role = "Switch";
      site = "home";

      interfaces = {
        "mngt" = {
          mac = "58:0a:20:9a:11:72";

          monitoring.services = [ "ICMP" "SNMP" ];
        };
      };
    };

    "br2" = {
      type = "Cisco SG 300-10";
      role = "Switch";
      site = "home";

      interfaces = {
        "mngt" = {
          mac = "08:cc:68:43:35:a2";

          monitoring.services = [ "ICMP" "SNMP" ];
        };
      };
    };

    "br3" = {
      type = "Cisco SG 300-10";
      role = "Switch";
      site = "home";

      interfaces = {
        "mngt" = {
          mac = "9c:57:ad:a0:ad:67";

          monitoring.services = [ "ICMP" "SNMP" ];
        };
      };
    };

    "phone" = {
      type = "Cisco SPA112";
      role = "SIP";
      site = "home";

      interfaces = {
        "mngt" = {
          mac = "00:e1:6d:b8:3c:53";

          monitoring.services = [ "ICMP" "SNMP" ];
        };
      };
    };

    "ap-downstairs" = {
      type = "Aruba AP11";
      role = "WiFi AP";
      site = "home";

      interfaces = {
        "mngt" = {
          mac = "bc:9f:e4:cc:90:3e";

          monitoring.services = [ "ICMP" ];
        };
      };
    };

    "ap-upstairs" = {
      type = "Aruba AP11";
      role = "WiFi AP";
      site = "home";

      interfaces = {
        "mngt" = {
          mac = "bc:9f:e4:cc:a6:26";

          monitoring.services = [ "ICMP" ];
        };
      };
    };

    "brueckenkopf" = {
      type = "Virtual Server";
      role = "Server";
      site = "hs";

      interfaces = {
        "ext" = {
          mac = "00:50:56:9c:d3:44";
          satelite = {
            addresses = [
              "193.174.29.6/27"
              "2001:638:301:27fd::6/64"
            ];
            gateways = [ "193.174.29.1" "2001:638:301:27fd::1" ];
            dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
            routes = [
              {
                destination = "193.174.29.32/27";
                gateway = "193.174.29.1";
              }
            ];
          };
        };
        "int" = {
          mac = "00:50:56:9c:68:c0";
        };
        "lab" = {
          mac = "00:50:56:9c:a5:49";
        };
      };
    };

    "paradeplatz" = {
      type = "Hyundai iTMC Pentino H-Series";
      role = "Server";
      site = "hs";

      interfaces = {
        "int" = { };
        "lab" = { };
      };
    };

    "raketensilo" = {
      type = "VMware Virtual Machine";
      role = "Server";
      site = "hs";

      interfaces = {
        "ext" = {
          mac = "00:50:56:9f:37:47";
          satelite = {
            addresses = [
              "2001:638:301:27fd::64/64"
            ];
            gateways = [ ];
            dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
          };
        };
        "int" = {
          mac = "00:50:56:9c:3b:f6";
        };
        "lab" = {
          mac = "00:50:56:9f:09:3d";
        };
      };
    };

    "fliegerhorst" = {
      type = "Virtual Server";
      role = "Server";
      site = null;

      interfaces = {
        "ext" = {
          mac = "00:50:56:3c:4e:1b";
          satelite = {
            addresses = [
              "193.34.144.95/25"
              "2a02:c205:3002:2452::1/64"
            ];
            gateways = [ "193.34.144.1" "fe80::1" ];
            dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
          };
        };
      };
    };

    "win10" = {
      type = "Virtual Server";
      role = "Server";
      site = "hs";
    };

    "builder-intel" = {
      type = "Virtual Server";
      role = "Server";
      site = "hs";

      interfaces = {
        "int" = {
          mac = "52:54:00:57:ff:27";
        };
      };
    };

    "builder-arm" = {
      type = "Virtual Server";
      role = "Server";
      site = null;

      interfaces = {
        "ext" = {
          mac = "02:00:17:00:32:cc";
          satelite = {
            addresses = [
              "10.0.0.63/24"
            ];
            gateways = [ "10.0.0.1" ];
            dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
          };
        };
      };
    };

    "bunker" = {
      type = "Virtual Server";
      role = "Server";
      site = null;

      interfaces = {
        "ext" = {
          mac = "96:00:01:a7:28:6c";
          satelite = {
            addresses = [
              "65.21.148.248/32"
              "2a01:4f9:c010:79da::/64"
            ];
            routes = [{
              # Point to point route for default gateway
              destination = "172.31.1.1/32";
              gateway = null;
            }];
            gateways = [ "172.31.1.1" "fe80::1" ];
            dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
          };
        };
      };
    };

    "zitadelle-north" = {
      type = "Virtual Server";
      role = "Server";
      site = null;

      interfaces = {
        "ext" = {
          mac = "96:00:01:8b:36:09";
          satelite = {
            addresses = [
              "88.198.178.118/32"
              "2a01:4f8:1c1c:43bb::/64"
            ];
            routes = [{
              # Point to point route for default gateway
              destination = "172.31.1.1/32";
              gateway = null;
            }];
            gateways = [ "172.31.1.1" "fe80::1" ];
            dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
          };
        };
      };
    };

    "zitadelle-south" = {
      type = "Virtual Server";
      role = "Server";
      site = null;

      interfaces = {
        "ext" = {
          mac = "96:00:01:8e:00:0d";
          satelite = {
            addresses = [
              "167.235.248.37/32"
              "2a01:4f8:c012:38ee::/64"
            ];
            routes = [{
              # Point to point route for default gateway
              destination = "172.31.1.1/32";
              gateway = null;
            }];
            gateways = [ "172.31.1.1" "fe80::1" ];
            dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
          };
        };
      };
    };

    "pv-inverter" = {
      type = "Deye SUN600G3-EU-230";
      role = "Microinverter";
      site = "home";

      interfaces = {
        "iot" = {
          mac = "E8:FD:F8:93:10:3C";
        };
      };
    };

  };
}
