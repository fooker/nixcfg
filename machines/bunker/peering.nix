{ config, lib, pkgs, name, ... }:

let
  secrets = import ./secrets.nix;
in
{
  peering = {
    routerId = "37.120.161.15";

    backhaul = {
      enable = true;

      deviceId = 3;

      dn42.ipv4 = "172.23.200.3/32";
      dn42.ipv6 = "fd79:300d:6056::3/128";
    };

    peers = {
      "backhaul.znorth".local.privkey = secrets.peering.privkeys."backhaul.znorth";
      "backhaul.zsouth".local.privkey = secrets.peering.privkeys."backhaul.zsouth";
    };
  };
}
