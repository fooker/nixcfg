{ config, lib, pkgs, name, peers, tools, ... }:

with lib;

domain: optionalString (domain.bgp != null) (
  let
    neighbors = concatMapStringsSep "\n"
      (peer: 
        let
          name = replaceStrings [ "." ] [ "_" ] peer.netdev;
          as = toString (if peer.bgp.as != null then peer.bgp.as else domain.bgp.as);

        in ''
          protocol bgp ${domain.name}_bgp_${name}_4 from ${domain.name}_bgp_4 {
            neighbor ${peer.transport.ipv4.peer} as ${as};
          }
          protocol bgp ${domain.name}_bgp_${name}_6 from ${domain.name}_bgp_6 {
            neighbor ${peer.transport.ipv4.peer} as ${as};
            interface "${peer.netdev}";
          }
        '')
      (peers domain "bgp");
    
    ipv4 = tools.ipinfo domain.ipv4;
    ipv6 = tools.ipinfo domain.ipv6;

  in ''
    ipv4 table ${domain.name}_egp_4;
    ipv6 table ${domain.name}_egp_6;

    protocol static ${domain.name}_static_4 {
      ${concatMapStringsSep "\n" (export: "route ${export} via \"${domain.name}\";") domain.exports.ipv4}

      ipv4 {
        table ${domain.name}_egp_4;
        import all;
        export none;
      };
    }

    protocol static ${domain.name}_static_6 {
      ${concatMapStringsSep "\n" (export: "route ${export} via \"${domain.name}\";") domain.exports.ipv6}

      ipv6 {
        table ${domain.name}_egp_6;
        import all;
        export none;
      };
    }

    ${optionalString(domain.bgp.roa != null) ''
      roa4 table ${domain.name}_roa_4;
      roa6 table ${domain.name}_roa_6;

      protocol static ${domain.name}_roa_static_4 {
        include "${domain.bgp.roa.ipv4}";

        roa4 {
          table ${domain.name}_roa_4;
          import all;
          export none;
        };
      }

      protocol static ${domain.name}_roa_static_6 {
        include "${domain.bgp.roa.ipv6}";

        roa6 {
          table ${domain.name}_roa_6;
          import all;
          export none;
        };
      }
    ''}

    template bgp ${domain.name}_bgp {
      local as ${toString domain.bgp.as};

      path metric on;

      check link on;
      direct;
    }

    template bgp ${domain.name}_bgp_4 from ${domain.name}_bgp {
      ipv4 {
        table ${domain.name}_egp_4;
        preference ${toString domain.bgp.preference};

        next hop self;

        import keep filtered;
        import limit 1000 action block;
        import filter {
          if net ~ [${ipv4.network}/${toString ipv4.netmask}+] then {
            print "[${domain.name}] Received local network from external: ", net, " from ", bgp_path.last;
            reject;
          }

          if ${domain.name}_exported_v4() then {
            print "[${domain.name}] Received own prefix from external: ", net, " from ", bgp_path.last;
            reject;
          }

          ${optionalString(domain.bgp.roa != null) ''
            if (roa_check(${domain.name}_roa_4, net, bgp_path.last) != ROA_VALID) then {
              print "[${domain.name}] ROA check failed: ", net, " from ", bgp_path.last;
              reject;
            }
          ''}

          if !${domain.name}_filtered_v4() then {
            print "[${domain.name}] Network not allowed: ", net, " from ", bgp_path.last;
            reject;
          }

          accept;
        };
        export filter {
          if ${domain.name}_exported_v4() then accept;
          if ${domain.name}_filtered_v4() then accept;

          print "[${domain.name}] Illegal export: ", net, " from ", bgp_path.last;
          reject;
        };
      };
    }

    template bgp ${domain.name}_bgp_6 from ${domain.name}_bgp {
      ipv6 {
        table ${domain.name}_egp_6;
        preference ${toString domain.bgp.preference};

        next hop self;

        import keep filtered;
        import limit 1000 action block;
        import filter {
          if net ~ [${ipv6.network}/${toString ipv6.netmask}+] then {
            print "[${domain.name}] Received local network from external: ", net, " from ", bgp_path.last;
            reject;
          }

          if ${domain.name}_exported_v6() then {
            print "[${domain.name}] Received own prefix from external: ", net, " from ", bgp_path.last;
            reject;
          }

          ${optionalString(domain.bgp.roa != null) ''
            if (roa_check(${domain.name}_roa_6, net, bgp_path.last) != ROA_VALID) then {
              print "[${domain.name}] ROA check failed: ", net, " from ", bgp_path.last;
              reject;
            }
          ''}

          if !${domain.name}_filtered_v6() then {
            print "[${domain.name}] Network not allowed: ", net, " from ", bgp_path.last;
            reject;
          }

          accept;
        };

        export filter {
          if ${domain.name}_exported_v6() then accept;
          if ${domain.name}_filtered_v6() then accept;

          print "[${domain.name}] Illegal export: ", net, " from ", bgp_path.last;
          reject;
        };
      };
    }

    ${neighbors}

    protocol pipe ${domain.name}_egp_pipe_4 {
      table ${domain.name}_egp_4;
      peer table ${domain.name}_4;

      import none;
      export all;
    }

    protocol pipe ${domain.name}_egp_pipe_6 {
      table ${domain.name}_egp_6;
      peer table ${domain.name}_6;

      import none;
      export all;
    }
  ''
)
