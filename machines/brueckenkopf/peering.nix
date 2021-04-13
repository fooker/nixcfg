{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  peering = {
    routerId = "1.2.3.6";

    backhaul = {
      enable = true;
      reachable = true;
      
      deviceId = 4;
      slug = "brkopf";

      netdev = "int";

      dn42.ipv4 = "172.23.200.33/28";
      dn42.ipv6 = "fd79:300d:6056:1::/64";
    };

    peers = {
      "backhaul.znorth".local.privkey = secrets.peering.privkeys."backhaul.znorth";
      "backhaul.zsouth".local.privkey = secrets.peering.privkeys."backhaul.zsouth";
    };
  };
}
