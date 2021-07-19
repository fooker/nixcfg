{ config, nodes, lib, ... }:

with lib;

{
  config = mkIf config.hive.enable {
    peering = {
      # Peering for hive relies on backhaul
      backhaul.enable = true;

      # Configure domain to use hive node addresses
      domains = {
        "hive" = {
          netdev = null;

          ipv4 = config.hive.self.address.ipv4.hostNetwork;
          ipv6 = config.hive.self.address.ipv6.hostNetwork;
        };
      };

      # Enable the hive domain for all related peers
      peers = listToAttrs (map
        (name: nameValuePair nodes.${ name }.config.peering.backhaul.key {
          domains = {
            "hive" = {
              ospf = { };
            };
          };
        })
        (attrNames config.hive.others));
    };
  };
}
