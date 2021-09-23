{ config, lib, pkgs, ... }:

with lib;

{
  options.firewall =
    let
      mkTable = description: options: mkOption {
        type = types.submodule ({
          inherit options;
        });
        inherit description;
        default = { };
      };

      mkChain = description: mkOption {
        type = with types; dagOf (coercedTo str singleton (listOf str));
        inherit description;
        default = { };
      };

      mkIngressChain = mkChain "Process all packets before they enter the system";
      mkPrerouteChain = mkChain "Process all packets entering the system";
      mkInputChain = mkChain "Process packets delivered to the local system";
      mkForwardChain = mkChain "Process packets forwarded to a different host";
      mkOutputChain = mkChain "Process packets sent by local processes";
      mkPostrouteChain = mkChain "Process all packets leaving the system";

    in
    {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Firewalling";
      };

      rules = mkOption {
        type = types.fnOf (types.submodule ({ ... }: {
          options = {
            ip = mkTable "internet (IPv4) address family netfilter table" {
              filter.prerouting = mkPrerouteChain;
              filter.input = mkInputChain;
              filter.forward = mkForwardChain;
              filter.output = mkOutputChain;
              filter.postrouting = mkPostrouteChain;
              nat.prerouting = mkPrerouteChain;
              nat.input = mkInputChain;
              nat.output = mkOutputChain;
              nat.postrouting = mkPostrouteChain;
              route.output = mkForwardChain;
            };
            ip6 = mkTable "internet (IPv6) address family netfilter table" {
              filter.prerouting = mkPrerouteChain;
              filter.input = mkInputChain;
              filter.forward = mkForwardChain;
              filter.output = mkOutputChain;
              filter.postrouting = mkPostrouteChain;
              nat.prerouting = mkPrerouteChain;
              nat.input = mkInputChain;
              nat.output = mkOutputChain;
              nat.postrouting = mkPostrouteChain;
              route.output = mkForwardChain;
            };
            inet = mkTable "internet (IPv4/IPv6) address family netfilter table" {
              filter.prerouting = mkPrerouteChain;
              filter.input = mkInputChain;
              filter.forward = mkForwardChain;
              filter.output = mkOutputChain;
              filter.postrouting = mkPostrouteChain;
              nat.prerouting = mkPrerouteChain;
              nat.input = mkInputChain;
              nat.output = mkOutputChain;
              nat.postrouting = mkPostrouteChain;
            };
            arp = mkTable "ARP (IPv4) address family netfilter table" {
              filter.input = mkInputChain;
              filter.output = mkOutputChain;
            };
            bridge = mkTable "bridge address family netfilter table" {
              filter.prerouting = mkPrerouteChain;
              filter.input = mkInputChain;
              filter.forward = mkForwardChain;
              filter.output = mkOutputChain;
              filter.postrouting = mkPostrouteChain;
            };
            netdev = mkTable "netdev address family netfilter table" {
              filter.ingress = mkIngressChain;
            };
          };
        }));
      };
    };

  config =
    let
      buildRule = { name, data }: concatMapStringsSep "\n"
        (rule: ''${ replaceStrings [ "\n" ] [ " " ] rule } comment "${ name }";'')
        data;

      buildChain = { type, chain, rules }: ''
        chain ${ chain } { type ${ type } hook ${ chain } priority 0;
        ${ concatMapStringsSep "\n" buildRule rules }
        }
      '';

      buildTable = table: types:
        let
          mkChain = type: chain: rules: {
            inherit type chain;
            rules = ((topoSort rules).result or (throw "Cycle in DAG"));
          };

          chains = concatLists
            (mapAttrsToList
              (type: chains: filter
                (chain: length chain.rules > 0)
                (mapAttrsToList (mkChain type) chains)
              )
              types
            );
        in
        optionalString (length chains > 0) ''
          table ${ table } nixos {
          ${ concatMapStringsSep "\n" buildChain chains }
          }
        '';

      rules = filterAttrsRecursive
        (name: _: name != "_module")
        (config.firewall.rules dagEntry);

    in
    mkIf config.firewall.enable {
      networking.firewall.enable = mkForce false;
      networking.firewall.package = mkDefault pkgs.iptables-nftables-compat;

      networking.nftables.enable = mkDefault true;

      networking.nftables.ruleset = mkDefault
        (concatStringsSep "\n"
          (mapAttrsToList buildTable rules)
        );

      firewall.rules = dag: with dag; {
        inet.filter.input = {
          loopback = before [ "drop" ] ''
            iifname lo
            accept
          '';

          established = between [ "loopback" ] [ "drop" ] ''
            ct state {
              established,
              related
            }
            accept
          '';

          basic-icmp6 = between [ "established" ] [ "drop" ] ''
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

          basic-icmp = between [ "established" ] [ "drop" ] ''
            ip protocol icmp
            icmp type {
              destination-unreachable,
              router-advertisement,
              time-exceeded,
              parameter-problem
            }
            accept'';

          ping = between [ "established" ] [ "basic-icmp" "drop" ] ''
            ip protocol icmp
            icmp type echo-request
            accept
          '';

          ping6 = between [ "established" ] [ "basic-icmp6" "drop" ] ''
            ip6 nexthdr icmpv6
            icmpv6 type echo-request
            accept
          '';

          mdns-ipv6 = between [ "established" ] [ "drop" ] ''
            udp dport mdns
            ip6 daddr ff02::fb
            accept
          '';

          mdns-ipv4 = between [ "established" ] [ "drop" ] ''
            udp dport mdns
            ip daddr 224.0.0.251
            accept
          '';

          drop = anywhere ''
            log level debug prefix "DROP: filter.input: "
            counter
            drop
          '';
        };

        inet.filter.output = {
          accept = anywhere ''
            accept
          '';
        };

        inet.filter.forward = {
          established = before [ "drop" ] ''
            ct state {
              established,
              related
            }
            accept
          '';

          drop = anywhere ''
            log level debug prefix "DROP: filter.forward: "
            counter
            drop
          '';
        };
      };

      # Disable loading of iptables even harder
      boot.extraModprobeConfig = ''
        install ip_tables ${pkgs.coreutils}/bin/false
      '';

      assertions =
        let
          ruleset = pkgs.writeText "nft-ruleset" config.networking.nftables.ruleset;
          check-results = pkgs.runCommand "check-nft-ruleset" { } ''
            mkdir -p $out
            ${pkgs.nftables}/bin/nft -c -f ${ruleset} 2>&1 > $out/message \
              && echo false > $out/assertion \
              || echo true > $out/assertion
          '';
        in
        [{
          message = "Bad config: ${builtins.readFile "${check-results}/message"}";
          assertion = import "${check-results}/assertion";
        }];
    };
}
