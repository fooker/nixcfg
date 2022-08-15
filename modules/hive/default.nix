{ config, lib, name, ... }:

with lib;

{
  options.hive =
    let
      nodeModule = types.submodule ({ name, ... }: {
        options = {
          id = mkOption {
            type = types.str;
            description = "Name (ID) of the node";
            default = name;
          };

          address.ipv4 = mkOption {
            type = types.ip.address.v4;
            description = "IPv4 address of the node";
          };
          address.ipv6 = mkOption {
            type = types.ip.address.v6;
            description = "IPv6 address of the node";
          };

          snowflake = mkOption {
            type = types.bool;
            description = "This node takes special handling";
            default = false;
          };
        };
      });

    in
    {
      enable = mkEnableOption "hive node";

      id = mkOption {
        type = types.str;
        description = "Name (ID) of this node";
        default = name;
      };

      nodes = mkOption {
        type = types.attrsOf nodeModule;
        description = "All nodes in the hive";
      };

      self = mkOption {
        type = nodeModule;
        description = "Node for this host";
      };

      others = mkOption {
        type = types.attrsOf nodeModule;
        description = "All nodes but this host";
      };
    };

  config = mkIf config.hive.enable {
    hive.self = config.hive.nodes."${config.hive.id}";
    hive.others = filterAttrs (_: node: node.id != config.hive.id) config.hive.nodes;
  };

  imports = [
    ./peering.nix
    ./mariadb.nix
    ./glusterfs.nix
    ./keydb.nix
  ];
}
