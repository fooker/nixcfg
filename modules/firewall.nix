{ config, lib, ext, pkgs, path, ... }:

with lib;

{
  options.firewall = 
    let
      mkTable = description: chains: mkOption {
        type = types.submodule({ config, ... }: {
          options = chains;
        });
        inherit description;
        default = {};
      };

      mkChain = family: description: mkOption {
        type = ext.dag.types.dagOf types.str;
        inherit description;
        default = {};
      };

      mkIngressChain = mkChain "Process all packets before they enter the system";
      mkPrerouteChain = mkChain "Process all packets entering the system";
      mkInputChain = mkChain "Process packets delivered to the local system";
      mkForwardChain = mkChain "Process packets forwarded to a different host";
      mkOutputChain = mkChain "Process packets sent by local processes";
      mkPostrouteChain = mkChain "Process all packets leaving the system";

    in {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Firewalling";
      };

      rules = mkOption {
        type = ext.fn.types.fnOf (types.submodule({ ... }: {
          options = {
            ip = mkTable "internet (IPv4) address family netfilter table" {
              filter.prerouting = mkPrerouteChain "ip";
              filter.input = mkInputChain "ip";
              filter.forward = mkForwardChain "ip";
              filter.output = mkOutputChain "ip";
              filter.postrouting = mkPostrouteChain "ip";
              nat.prerouting = mkPrerouteChain "ip";
              nat.input = mkInputChain "ip";
              nat.output = mkOutputChain "ip";
              nat.postrouting = mkPostrouteChain "ip";
              route.output = mkForwardChain "ip";
            };
            ip6 = mkTable "internet (IPv6) address family netfilter table" {
              filter.prerouting = mkPrerouteChain "ip6";
              filter.input = mkInputChain "ip6";
              filter.forward = mkForwardChain "ip6";
              filter.output = mkOutputChain "ip6";
              filter.postrouting = mkPostrouteChain "ip6";
              nat.prerouting = mkPrerouteChain "ip6";
              nat.input = mkInputChain "ip6";
              nat.output = mkOutputChain "ip6";
              nat.postrouting = mkPostrouteChain "ip6";
              route.output = mkForwardChain "ip6";
            };
            inet = mkTable "internet (IPv4/IPv6) address family netfilter table" {
              filter.prerouting = mkPrerouteChain "inet";
              filter.input = mkInputChain "inet";
              filter.forward = mkForwardChain "inet";
              filter.output = mkOutputChain "inet";
              filter.postrouting = mkPostrouteChain "inet";
              nat.prerouting = mkPrerouteChain "inet";
              nat.input = mkInputChain "inet";
              nat.output = mkOutputChain "inet";
              nat.postrouting = mkPostrouteChain "inet";
            };
            arp = mkTable "ARP (IPv4) address family netfilter table" {
              filter.input = mkInputChain "arp";
              filter.output = mkOutputChain "arp";
            };
            bridge = mkTable "bridge address family netfilter table" {
              filter.prerouting = mkPrerouteChain "bridge";
              filter.input = mkInputChain "bridge";
              filter.forward = mkForwardChain "bridge";
              filter.output = mkOutputChain "bridge";
              filter.postrouting = mkPostrouteChain "bridge";
            };
            netdev = mkTable "netdev address family netfilter table" {
              filter.ingress = mkIngressChain "netdev";
            };
          };
        }));
      };
    };

  config = 
    let
      buildRule = { name, data }: ''
        ${ replaceStrings [ "\n" ] [ " " ] data } comment "${ name }";
      '';

      buildChain = { type, chain, rules }: ''
        chain ${ chain } { type ${ type } hook ${ chain } priority 0;
        ${ concatMapStringsSep "\n" buildRule rules }
        }
      '';

      buildTable = table: types:
        let
          mkChain = type: chain: rules: {
            inherit type chain;
            rules = ((ext.dag.topoSort rules).result or (throw "Cycle in DAG"));
          };

          chains = concatLists
            (mapAttrsToList
              (type: chains: filter
                (chain: length chain.rules > 0)
                (mapAttrsToList (mkChain type) chains)
              )
              types
            );
        in optionalString (length chains > 0) ''
          table ${ table } nixos {
          ${ concatMapStringsSep "\n" buildChain chains }
          }
        '';
      
      rules = filterAttrsRecursive
        (name: value: name != "_module")
        (config.firewall.rules ext.dag.entry);

    in mkIf config.firewall.enable {
      networking.firewall.enable = mkForce false;
      networking.firewall.package = mkDefault pkgs.iptables-nftables-compat;

      networking.nftables.enable = mkDefault true;

      networking.nftables.ruleset = mkDefault 
        (concatStringsSep "\n" 
          (mapAttrsToList buildTable rules)
        );
      
      firewall.rules = dag: with dag; {
        inet.filter.input = {
          loopback = before ["drop"] ''
            iifname lo
            accept
          '';
          
          established = between ["loopback"] ["drop"] ''
            ct state {
              established,
              related
            }
            accept
          '';

          basic-icmp6 = between ["established"] ["drop"] ''
            ip6 nexthdr icmpv6
            icmpv6 type {
              destination-unreachable,
              packet-too-big,
              time-exceeded,
              parameter-problem,
              nd-router-advert,
              nd-neighbor-solicit,
              nd-neighbor-advert
            }
            accept'';

          basic-icmp = between ["established"] ["drop"] ''
            ip protocol icmp
            icmp type {
              destination-unreachable,
              router-advertisement,
              time-exceeded,
              parameter-problem
            }
            accept'';
          
          ping = between ["established"] ["basic-icmp" "drop"] ''
            ip protocol icmp
            icmp type echo-request
            accept
          '';

          ping6 = between ["established"] ["basic-icmp6" "drop"] ''
            ip6 nexthdr icmpv6
            icmpv6 type echo-request
            accept
          '';

          drop = anywhere ''
            drop
          '';
        };

        inet.filter.output = {
          accept = anywhere ''
            accept
          '';
        };

        inet.filter.forward = {
          drop = anywhere ''
            drop
          '';
        };
      };

      assertions = 
        let
          ruleset = pkgs.writeText "nft-ruleset" config.networking.nftables.ruleset;
          check-results = pkgs.runCommand "check-nft-ruleset" {} ''
            mkdir -p $out
            ${pkgs.nftables}/bin/nft -c -f ${ruleset} 2>&1 > $out/message \
              && echo false > $out/assertion \
              || echo true > $out/assertion
          '';
        in [ {
          message = "Bad config: ${builtins.readFile "${check-results}/message"}";
          assertion = import "${check-results}/assertion";
        } ];
    };
}
