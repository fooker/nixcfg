let
  secrets = import ./secrets.nix;
in
{
  peering = {
    routerId = "1.2.3.6";

    backhaul = {
      enable = true;
      reachable = true;

      deviceId = 4;
      slug = "brkopf";

      netdev = "int";
    };
  };
}
