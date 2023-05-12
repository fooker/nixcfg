let
  secrets = import ./secrets.nix;
in
{
  peering = {
    routerId = "1.2.3.5";

    backhaul = {
      enable = true;
      reachable = false;

      deviceId = 127;

      dn42.ipv4 = "172.23.200.127/32";
      dn42.ipv6 = "fd79:300d:6056:ffff::0/128";

      extraPeers = [ "brueckenkopf" ];
    };
  };
}
