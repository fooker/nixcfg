{ config, lib, pkgs, name, tools, ... }:

with lib;

# TODO: Firewall rules for wireguard

{
  imports = [
    ./bird
  ];

  options.backhaul = {
    routerId = mkOption {
      description = "The router ID of the machine";
      type = types.str;
    };

    domains = mkOption {
      description = "Routing Domains this machine participates in";
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          name = mkOption {
            description = "Name of the domain";
            default = name;
            type = types.str;
          };

          netdev = mkOption {
            description = "Name of the local network interface - keep undefined for dummy interface";
            default = null;
            type = types.nullOr types.str;
          };

          ipv4 = mkOption {
            description = "IPv4 address/network of the node in this domain (CIDR notation)";
            type = types.str;
          };

          ipv6 = mkOption {
            description = "IPv6 address/network of the node in this domain (CIDR notation)";
            type = types.str;
          };

          bgp = mkOption {
            description = "BGP configuration";
            default = null;
            type = types.nullOr (types.submodule {
              options = {
                as = mkOption {
                  description = "The AS the machine is in";
                  type = types.ints.unsigned;
                };
                
                preference = mkOption {
                  description = "Route preference";
                  type = types.ints.u16;
                };

                roa = mkOption {
                  description = "Path to ROA table data";
                  default = null;
                  type = types.nullOr (types.submodule {
                    options = {
                      ipv4 = mkOption {
                        description = "Path to IPv4 ROA table data";
                        type = types.str;
                      };

                      ipv6 = mkOption {
                        description = "Path to IPv6 ROA table data";
                        type = types.str;
                      };
                    };
                  });
                };
              };
            });
          };

          ospf = mkOption {
            description = "OSPF configuration";
            default = null;
            type = types.nullOr (types.submodule {
              options = {
                instanceId = mkOption {
                  type = types.ints.u16;
                  description = "The OSPF instance ID";
                };

                preference = mkOption {
                  type = types.ints.u16;
                  description = "Route preference";
                };
              };
            });
          };

          babel = mkOption {
            description = "Babel configuration";
            default = null;
            type = types.nullOr (types.submodule {
              options = {};
            });
          };

          exports = {
            ipv4 = mkOption {
              description = "The IPv4 routes exported by this node to this domain";
              default = [];
              type = types.listOf types.str;
            };
            ipv6 = mkOption {
              description = "The IPv4 routes exported by this node to this domain";
              default = [];
              type = types.listOf types.str;
            };
          };

          filters = {
            ipv4 = mkOption {
              description = "The IPv4 routes to import by this node in this domain";
              default = [];
              type = types.listOf types.str;
            };
            ipv6 = mkOption {
              description = "The IPv6 routes to import by this node in this domain";
              default = [];
              type = types.listOf types.str;
            };
          };
        };
      }));
    };

    peers = mkOption {
      description = "Backhaul peers";
      default = {};
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          netdev = mkOption {
            description = "Name of the network interface";
            default = "peer.x.${name}";
            type = types.str;
          };

          local.port = mkOption {
            description = "Local port";
            default = null;
            type = types.nullOr types.port;
          };

          local.privkey = mkOption {
            description = "Local private key";
            type = types.str;
          };

          remote.host = mkOption {
            description = "Remote host";
            type = types.str;
          };

          remote.port = mkOption {
            description = "Remote port";
            type = types.port;
          };

          remote.pubkey = mkOption {
            description = "Remote public key";
            type = types.str;
          };

          transport.ipv4.addr = mkOption {
            description = "Local IPv4 address";
            type = types.str;
          };

          transport.ipv4.peer = mkOption {
            description = "Remote IPv4 address";
            type = types.str;
          };

          transport.ipv6.addr = mkOption {
            description = "Local IPv6 address";
            type = types.str;
          };

          transport.ipv6.peer = mkOption {
            description = "Remote IPv6 address";
            type = types.str;
          };

          domains = mkOption {
            description = "Routing Domains this peer participates in";
            type = types.attrsOf (types.submodule ({ name, ... }: {
              options = {
                bgp = mkOption {
                  description = "Peer BGP configuration";
                  default = null;
                  type = types.nullOr (types.submodule {
                    options = {
                      as = mkOption {
                        description = "The AS of the peer (or null for interior routing)";
                        default = null;
                        type = types.nullOr types.ints.unsigned;
                      };
                    };
                  });
                };

                ospf = mkOption {
                  description = "Peer OSPF configuration";
                  default = null;
                  type = types.nullOr (types.submodule {
                    options = {
                    };
                  });
                };

                babel = mkOption {
                  description = "Peer Babel configuration";
                  default = null;
                  type = types.nullOr (types.submodule {
                    options = {
                    };
                  });
                };
              };
            }));
          };
        };
      }));
    };
  };

  config = let
    writePrivateKey = peer: key: pkgs.writeTextFile {
      name = "backhaul-peering-${name}-${peer}.key";
      text = key;
    };

    mkPeerNetwork = peer: cfg: {
      netdevs."80-backhaul-peer-${peer}" = {
        netdevConfig = {
          Description = "Peering with ${peer}";
          Name = "${cfg.netdev}";
          Kind = "wireguard";
        };
        wireguardConfig = {
          ListenPort = cfg.local.port;
          PrivateKeyFile = writePrivateKey peer cfg.local.privkey;
        };
        wireguardPeers = [{
          wireguardPeerConfig = {
            Endpoint = "${cfg.remote.host}:${toString cfg.remote.port}";
            AllowedIPs = "0.0.0.0/0, ::/0";
            PublicKey = "${cfg.remote.pubkey}";
            PersistentKeepalive = 25;
          };
        }];
      };

      networks."80-backhaul-peer-${peer}" = {
        matchConfig = {
          Name = "${cfg.netdev}";
        };
        networkConfig = {
          Description = "Peering with ${peer}";

          LinkLocalAddressing = "no";
          IPv6AcceptRA = false;
        };
        addresses = [
          { 
            addressConfig = {
              Address = "${cfg.transport.ipv4.addr}/32";
              Peer = "${cfg.transport.ipv4.peer}/32";
              Scope = "link";
            };
          }
          {
            addressConfig = {
              Address = "${cfg.transport.ipv6.addr}/128";
              Peer = "${cfg.transport.ipv6.peer}/128";
              Scope = "link";
            };
          }
        ];
      };
    };

    mkDomainNetwork = domain: {
      netdevs."70-backhaul-domain-${domain.name}" = {
        netdevConfig = {
          Description = "Domain ${domain.name}";
          Name = "${domain.name}";
          Kind = "dummy";
        };
      };

      networks."70-backhaul-domain-${domain.name}" = {
        matchConfig = {
          Name = "${domain.name}";
        };
        networkConfig = {
          Description = "Domain ${domain.name}";
        };
        addresses = [
          {
            addressConfig = with tools.ipinfo domain.ipv4; {
              Address = "${address}/${toString netmask}";
            };
          }
          {
            addressConfig = with tools.ipinfo domain.ipv6; {
              Address = "${address}/${toString netmask}";
            };
          }
        ];
      };
    };
    
  in mkIf (config.backhaul.peers != {}) {
    boot.extraModulePackages = mkIf (versionOlder config.boot.kernelPackages.kernel.version "5.6") [ config.boot.kernelPackages.wireguard ];
    environment.systemPackages = [ pkgs.wireguard-tools ];

    systemd.network = mkMerge (flatten [
      (mapAttrsToList mkPeerNetwork config.backhaul.peers)
      (map
        mkDomainNetwork
        (filter # Filter domains with standalone interface and having at least one peer
          (domain: and
            (any # Check if domain has any peer
              (peer: hasAttr domain.name peer.domains) # Check if peer is associated with domain
              (attrValues config.backhaul.peers))
            (domain.netdev == null)) # Check if domain has associated local interface
          (attrValues config.backhaul.domains)))
    ]);
  };
}
