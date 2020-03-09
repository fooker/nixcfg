{ config, lib, peers, tools, ... }:

# TODO: Log rejected routes

with lib;

domain: optionalString (domain.babel != null) (
  let
    interfaces = concatMapStringsSep "\n"
      (peer: ''
        interface "${peer.netdev}" {
          type wired;
          check link on;

          next hop ipv4 ${peer.transport.ipv4.peer };
          next hop ipv6 ${peer.transport.ipv6.peer };
        };
      '')
      (peers domain "babel");
    
    ipv4 = tools.ipinfo domain.ipv4;
    ipv6 = tools.ipinfo domain.ipv6;

  in ''
    protocol babel ${domain.name}_babel {
      ipv4 {
        table ${domain.name}_4;

        import keep filtered;
        import filter {
          if net ~ [${ipv4.network}/${toString ipv4.netmask}+] then reject;
          if ${domain.name}_exported_v4() then accept;
          if ${domain.name}_filtered_v4() then accept;

          reject;
        };
        export filter {
          if ${domain.name}_exported_v4() then accept;
          if ${domain.name}_filtered_v4() then accept;

          reject;
        };
      };

      ipv6 {
        table ${domain.name}_6;

        import keep filtered;
        import filter {
          if net ~ [${ipv6.network}/${toString ipv6.netmask}+] then reject;
          if ${domain.name}_exported_v6() then accept;
          if ${domain.name}_filtered_v6() then accept;

          reject;
        };
        export filter {
          if ${domain.name}_exported_v6() then accept;
          if ${domain.name}_filtered_v6() then accept;

          reject;
        };
      };

      ${interfaces}
    }
  ''
)
