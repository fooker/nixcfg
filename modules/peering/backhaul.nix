{ config, nodes, lib, pkgs, name, tools, ... }:


with lib;

let
  portBase = 23230;

in {
  options.peering.backhaul = {
    enable = mkEnableOption "internal backhaul peering";

    deviceId = mkOption {
      description = "Internal ID of the device";
      type = types.ints.u8;
    };

    slug = mkOption {
      description = "Short name for the peer";
      type = types.str;
      default = name;
    };

    key = mkOption {
      description = "Key to identify the peer in peering tables";
      type = types.str;
      default = "backhaul.${ config.peering.backhaul.slug }";
      readOnly = true;
    };

    hub = mkEnableOption "this node as a hub";

    netdev = mkOption {
      description = "Name of the local network interface - keep undefined for dummy interface";
      default = null;
      type = types.nullOr types.str;
    };

    dn42.ipv4 = mkOption {
      description = "IPv4 address/network of the node in DN42 (CIDR notation)";
      type = types.str;
    };

    dn42.ipv6 = mkOption {
      description = "IPv6 address/network of the node in DN42 (CIDR notation)";
      type = types.str;
    };

    reachable = mkOption {
      description = "Whether the node is reachable by other nodes or not";
      type = types.bool;
      default = true; 
    };
  };

  config = let 
    # The backhaul config of the local node
    local = config.peering.backhaul // { inherit name; };

    # The backhaul config of all "other" nodes
    others = mapAttrsToList
        (name: node: node.config.peering.backhaul // { inherit name; })
        (removeAttrs nodes [ name ]);

    # The backhaul config of all nodes to peer with
    peers = filter
      (node: and
        # Backhaul must be enabled
        node.enable

        # Either this node is a hub and we peer with everybody or we peer with all hubs
        (config.peering.backhaul.hub || node.hub))
      others;
    
  in mkIf config.peering.backhaul.enable {
    
    # Every node in backhaul is part of DN42
    peering.domains = {
      "dn42" = {
        netdev = config.peering.backhaul.netdev;

        ipv4 = config.peering.backhaul.dn42.ipv4;
        ipv6 = config.peering.backhaul.dn42.ipv6;
      };
    };

    peering.peers = listToAttrs (map
      (peer: nameValuePair peer.key {
        inherit (peer) name;

        netdev = "peer.x.${ peer.slug }";

        local.port = if local.reachable
          then portBase + peer.deviceId
          else null;
          
        remote.endpoint = if peer.reachable
          then {
            host = nodes.${ peer.name }.config.dns.host.domain.toSimpleString;
            port = portBase + local.deviceId;
          } else null;

        remote.pubkey = nodes.${ peer.name }.config.peering.peers.${ local.key }.local.pubkey;

        transfer = {
          ipv4.addr = "100.64.${ toString local.deviceId }.${ toString peer.deviceId }";
          ipv4.peer = "100.64.${ toString peer.deviceId }.${ toString local.deviceId }";

          ipv6.addr = "fe80::${ toHexString local.deviceId }:${ toHexString peer.deviceId }";
          ipv6.peer = "fe80::${ toHexString peer.deviceId }:${ toHexString local.deviceId }";
        };

        domains = {
          "dn42" = {
            babel = {};
          };
        };
      })
      peers);
  };
}