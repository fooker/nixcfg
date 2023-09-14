{ config, lib, pkgs, ... }:

with lib;

{
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
}
