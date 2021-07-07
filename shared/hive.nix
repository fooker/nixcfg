{ config, lib, pkgs, ... }:

with lib;
{
  hive.nodes = {
    "zitadelle-north" = {
      address.ipv4 = "192.168.33.1";
      address.ipv6 = "fd4c:8f0:aff2::1";
    };

    "zitadelle-south" = {
      address.ipv4 = "192.168.33.2";
      address.ipv6 = "fd4c:8f0:aff2::2";
    };

    "bunker" = {
      address.ipv4 = "192.168.33.3";
      address.ipv6 = "fd4c:8f0:aff2::3";

      snowflake = true;
    };
  };
}
