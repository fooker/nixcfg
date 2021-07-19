{ lib, ... }:

with lib;

domain: peers:
let
  interfaces = concatMapStringsSep "\n"
    (peer: ''
      interface "${peer.netdev}" {
        type pointopoint;
        check link on;
      };
    '')
    peers;

in
''
  protocol ospf v2 ${domain.name}_ospf_4 {
    instance id ${toString domain.ospf.instanceId};

    area 0 {
      ${interfaces}
    };

    ipv4 {
      table ${domain.name}_4;
      preference ${toString domain.ospf.preference};

      import keep filtered;
      import filter {
        if net ~ [${toString domain.ipv4.prefix}+] then reject;
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
  }

  protocol ospf v3 ${domain.name}_ospf_6 {
    rfc5838 no;
    instance id ${toString domain.ospf.instanceId};

    area 0 {
      ${interfaces}
    };

    ipv6 {
      table ${domain.name}_6;
      preference ${toString domain.ospf.preference};

      import keep filtered;
      import filter {
        if net ~ [${toString domain.ipv6.prefix}+] then reject;
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
  }
''
