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
        "priv" = {
          mac = "b8:ae:ed:7d:69:ab";
        };
      };
    };

    "prusa" = {
      type = "Raspberry Pi 3 Model B+";
      role = "3D-Printer";
      site = "home";

      interfaces = {
        "priv" = {
          mac = "b8:27:eb:38:ed:66";
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
        };
      };
    };

    "scanner" = {
      type = "Raspberry Pi 3 Model B+";
      role = "2D-Scanner";
      site = "home";

      interfaces = {
        "priv" = {
          mac = "b8:27:eb:cb:20:ed";
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
        };
      };
    };

    "ap-downstairs" = {
      type = "Aruba AP11";
      role = "WiFi AP";
      site = "home";

      interfaces = {
        "mngt" = {
          mac = "";
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
              "2001:638:301:11a3::6/64"
            ];
            gateways = [ "193.174.29.1" "2001:638:301:11a3::1" ];
            dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
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
              "2001:638:301:11a3::64/64"
            ];
            gateways = [ "2001:638:301:11a3::1" ];
            dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
          };
        };
        "int" = { };
        "lab" = { };
      };
    };

    "builder" = {
      type = "Virtual Server";
      role = "Server";
      site = "hs";

      interfaces = {
        "int" = {
          mac = "52:54:00:57:ff:27";
        };
      };
    };

    "bunker" = {
      type = "Virtual Server";
      role = "Server";
      site = null;

      interfaces = {
        "ext" = {
          mac = "52:54:10:e9:1b:37";
          satelite = {
            addresses = [
              "37.120.161.15/22"
              "2a03:4000:6:30f2::/64"
            ];
            gateways = [ "37.120.160.1" "fe80::1" ];
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
          mac = "52:54:6e:09:06:f3";
          satelite = {
            addresses = [
              "37.120.172.185/22"
              "2a03:4000:6:701e::/64"
            ];
            gateways = [ "37.120.172.1" "fe80::1" ];
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
          mac = "52:54:5a:81:b4:b2";
          satelite = {
            addresses = [
              "37.120.172.177/22"
              "2a03:4000:6:701d::/64"
            ];
            gateways = [ "37.120.172.1" "fe80::1" ];
            dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
          };
        };
      };
    };
  };
}
