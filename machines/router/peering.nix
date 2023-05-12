let
  secrets = import ./secrets.nix;
in
{
  peering = {
    routerId = "1.2.3.4";

    backhaul = {
      enable = true;
      reachable = false;

      deviceId = 129;

      netdev = "priv";
    };
  };
}
