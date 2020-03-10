{ config, lib, pkgs, ... }:

with lib;
{
  config.backhaul.domains = {
    hive = {
      ospf = {
        instanceId = 23;
        preference = 1000;
      };

      exports.ipv4 = [
        "192.168.33.0/24"
      ];
      exports.ipv6 = [
        "fd4c:8f0:aff2::/64"
      ];
      filters.ipv4 = [
        "192.168.33.1/32"
        "192.168.33.2/32"
        "192.168.33.3/32"
      ];
      filters.ip6 = [
        "fd4c:8f0:aff2::1/128"
        "fd4c:8f0:aff2::2/128"
        "fd4c:8f0:aff2::3/128"
      ];
    };
    dn42 = {
      bgp = {
        as = 4242421271;
        preference = 200;
      };
      
      babel = {};

      ospf = {
        instanceId = 42;
        preference = 200;
      };

      exports.ipv4 = [
        "172.23.200.0/24"
      ];
      exports.ipv6 = [
        "fd79:300d:6056::/48"
      ];
      filters.ipv4 = [
        "172.20.0.0/14{21,29}" # dn42
        "172.20.0.0/24{28,32}" # dn42 Anycast
        "172.21.0.0/24{28,32}" # dn42 Anycast
        "172.22.0.0/24{28,32}" # dn42 Anycast
        "172.23.0.0/24{28,32}" # dn42 Anycast
        "172.31.0.0/16+"       # ChaosVPN
        "10.100.0.0/14+"       # ChaosVPN
        "10.0.0.0/8+"          # Freifunk
      ];
      filters.ipv6 = [
        "fc00::/7{44,64}"      # ULAs
      ];
    };
  };
}