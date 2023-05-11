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

    peers = {
      "backhaul.znorth".local.privkey = secrets.peering.privkeys."backhaul.znorth";
      "backhaul.zsouth".local.privkey = secrets.peering.privkeys."backhaul.zsouth";
      "backhaul.notebook".local.privkey = secrets.peering.privkeys."backhaul.notebook";
    };
  };
}
