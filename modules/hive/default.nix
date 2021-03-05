{ config, lib, pkgs, name, ... }:

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
            type = types.str;
            description = "IPv4 address of the node";
          };
          address.ipv6 = mkOption {
            type = types.str;
            description = "IPv6 address of the node";
          };

          snowflake = mkOption {
            type = types.bool;
            description = "This node takes special handling";
            default = false;
          };
        };
      });

    in {
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

    dns.host.ipv4 = config.hive.self.address.ipv4;
    dns.host.ipv6 = config.hive.self.address.ipv6;
  };

  imports = [
    ./mariadb.nix
    ./glusterfs.nix
  ];
}