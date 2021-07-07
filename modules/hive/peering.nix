{ config, nodes, lib, pkgs, ... }:

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

          ipv4 = "${config.hive.self.address.ipv4}/32";
          ipv6 = "${config.hive.self.address.ipv6}/128";
        };
      };

      # Enable the hive domain for all related peers
      peers = mapAttrs'
        (name: node: nameValuePair nodes.${ name }.config.peering.backhaul.key {
          domains = {
            "hive" = {
              ospf = { };
            };
          };
        })
        config.hive.others;
    };
  };
}
