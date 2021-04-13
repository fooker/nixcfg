{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  peering = {
    routerId = "1.2.3.4";

    backhaul = {
      enable = true;
      reachable = false;
      
      deviceId = 129;

      netdev = "priv";

      dn42.ipv4 = "172.23.200.129/25";
      dn42.ipv6 = "fd79:300d:6056:100::0/64";
    };

    peers = {
      "backhaul.znorth".local.privkey = secrets.peering.privkeys."backhaul.znorth";
      "backhaul.zsouth".local.privkey = secrets.peering.privkeys."backhaul.zsouth";
    };
  };
}
