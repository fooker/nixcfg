{ config, lib, pkgs, name, tools, ... }@args:

with lib;

let
  contains = x: l: any (e: e == x) l;
   
  peers = domain: protocol: filter 
    (peer: (hasAttr protocol peer) && (contains domain.name peer.domains))
    (attrValues config.backhaul.peers);

  exports.ipv4 = domain: concatMapStringsSep ", " (export: "${export}+") domain.exports.ipv4;
  exports.ipv6 = domain: concatMapStringsSep ", " (export: "${export}+") domain.exports.ipv6;

  filters.ipv4 = domain: concatStringsSep ", " domain.filters.ipv4;
  filters.ipv6 = domain: concatStringsSep ", " domain.filters.ipv6;

  args' = args // { inherit peers; };

  bgp = import ./bgp.nix args';
  ospf = import ./ospf.nix args';
  babel = import ./babel.nix args';

  domains = concatMapStringsSep "\n"
    (domain:
      let
        ipv4 = tools.ipinfo domain.ipv4;
        ipv6 = tools.ipinfo domain.ipv6;
      in ''
        ipv4 table ${domain.name}_4;
        ipv6 table ${domain.name}_6;

        function ${domain.name}_exported_v4() {
          return net ~ [ ${exports.ipv4 domain} ];
        }
        function ${domain.name}_filtered_v4() {
          return net ~ [ ${filters.ipv4 domain} ];
        }
        function ${domain.name}_exported_v6() {
          return net ~ [ ${exports.ipv6 domain} ];
        }
        function ${domain.name}_filtered_v6() {
          return net ~ [ ${filters.ipv6 domain} ];
        }

        protocol direct ${domain.name}_direct {
          interface "${domain.name}";
          check link yes;

          ipv4 {
            table ${domain.name}_4;
            import all;
            export none;
          };

          ipv6 {
            table ${domain.name}_6;
            import all;
            export none;
          };
        }

        ${bgp domain}
        ${ospf domain}
        ${babel domain}

        protocol pipe ${domain.name}_pipe_4 {
          table ${domain.name}_4;
          peer table output_4;

          import none;
          export filter {
            krt_prefsrc = ${ipv4.address};
            if net ~ [${ipv4.network}/${toString ipv4.netmask}+] then reject;

            accept;
          };
        }

        protocol pipe ${domain.name}_pipe_6 {
          table ${domain.name}_6;
          peer table output_6;

          import none;
          export filter {
            krt_prefsrc = ${ipv6.address};
            if net ~ [${ipv6.network}/${toString ipv6.netmask}+] then reject;

            accept;
          };
        }
      '')
    (filter
      # Check if domain is used by any peer
      (domain: any
        (peer: contains domain.name peer.domains)
        (attrValues config.backhaul.peers))
      (attrValues config.backhaul.domains));

in ''
  router id ${config.backhaul.routerId};

  protocol device {
    scan time 10;
  }

  ipv4 table output_4;
  ipv6 table output_6;

  protocol kernel output_kernel_4 {
    persist;
    learn;

    ipv4 {
      table output_4;
      import none;
      export all;
    };
  }

  protocol kernel output_kernel_6 {
    persist;
    learn;

    ipv6 {
      table output_6;
      import none;
      export all;
    };
  }

  ${domains}     
''
