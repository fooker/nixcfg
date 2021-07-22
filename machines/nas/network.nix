{ lib, ... }:

with lib;

{
  network = {
    enable = true;
    ipam = true;

    interfaces = {
      "priv-1" = "24:5e:be:35:8b:d5";
      "priv-2" = "24:5e:be:35:8b:d6";
      "priv-3" = "24:5e:be:35:8b:d7";
      "priv-4" = "24:5e:be:35:8b:d8";
    };
  };

  systemd.network = {
    netdevs = {
      "30-priv" = {
        netdevConfig = {
          Name = "priv";
          Kind = "bond";
        };
        bondConfig = {
          Mode = "802.3ad";
          TransmitHashPolicy = "layer3+4";
          LACPTransmitRate = "fast";
        };
      };
    };

    networks = {
      "20-priv" = {
        name = "priv-[1234]";
        bond = [ "priv" ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };
    };
  };
}
