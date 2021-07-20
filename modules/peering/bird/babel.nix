{ lib, ... }:

with lib;

domain: peers:
let
  interfaces = concatMapStringsSep "\n"
    (peer: ''
      interface "${peer.netdev}" {
        type wired;
        check link on;

        next hop ipv4 ${toString peer.transfer.ipv4.addr};
        next hop ipv6 ${toString peer.transfer.ipv6.addr};
      };
    '')
    peers;

in
''
  protocol babel ${domain.name}_babel {
    randomize router id yes;

    ipv4 {
      table ${domain.name}_4;

      import keep filtered;
      import filter {
        if net ~ [${toString (ip.network.prefixNetwork domain.ipv4)}+] then reject;
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
        if net ~ [${toString (ip.network.prefixNetwork domain.ipv6)}+] then reject;
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
