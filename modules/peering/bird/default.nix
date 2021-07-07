{ config, lib, tools, ... }@args:

with lib;

let
  exports.ipv4 = domain: concatMapStringsSep ", " (export: "${export}+") domain.exports.ipv4;
  exports.ipv6 = domain: concatMapStringsSep ", " (export: "${export}+") domain.exports.ipv6;

  filters.ipv4 = domain: concatStringsSep ", " domain.filters.ipv4;
  filters.ipv6 = domain: concatStringsSep ", " domain.filters.ipv6;

  /* All domains which have at least one peer participating
  */
  domains = filter
    (domain: any
      (peer: hasAttr domain.name peer.domains)
      (attrValues config.peering.peers))
    (attrValues config.peering.domains);

  domainConfig = domain:
    let
      ipv4 = tools.ipinfo domain.ipv4;
      ipv6 = tools.ipinfo domain.ipv6;

      netdev = if (domain.netdev != null) then domain.netdev else domain.name;

      /* Calls a protocol specific implementation if there are peers for this
        protocol. The protocol implementation must accept the domain
        configuration and the list of associated peer configurations.
      */
      callProtocol = protocol:
        let
          /* Find all peers working in the current domain and having a
            configuration for the given protocol.

            The returned list of peers is empty, if the domain is not configured
            for the protocol. Else, it will contian only peers wich are
            configured for the current domain and the given protocol in this
            domain.
          */
          peers = optionals (domain."${protocol}" != null) (filter
            (peer: (attrByPath [ domain.name protocol ] null peer.domains) != null) # Peer is configured for proto
            (attrValues config.peering.peers));

          /* Import the protocol implementation
          */
          impl = import (./. + "/${protocol}.nix") args;
        in
        optionalString (peers != [ ]) (impl domain peers);

    in
    ''
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
        interface "${netdev}";
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

      ${callProtocol "bgp"}
      ${callProtocol "ospf"}
      ${callProtocol "babel"}

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
    '';

in
mkIf (domains != [ ]) {
  services.bird2 = {
    enable = true;
    config = ''
      router id ${config.peering.routerId};

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

      ${concatMapStringsSep "\n" domainConfig domains}
    '';
  };

  firewall.rules = dag: with dag; {
    inet.filter.input =
      let
        mkProto = peer: proto: rule:
          optional
            (any
              (domain: (domain.${proto} or null) != null)
              (attrValues peer.domains))
            (nameValuePair
              "peering-${peer.name}-${proto}"
              (between [ "established" ] [ "drop" ] rule)
            );

        mkPeer = peer: concatLists [
          (mkProto peer "ospf" ''
            meta iifname "${peer.netdev}"
            meta l4proto OSPFIGP
            accept
          '')
          (mkProto peer "babel" ''
            meta iifname "${peer.netdev}"
            udp dport babel
            accept
          '')
          (mkProto peer "bgp" ''
            meta iifname "${peer.netdev}"
            tcp dport bgp
            accept
          '')
        ];

      in
      listToAttrs (concatMap
        mkPeer
        (attrValues config.peering.peers)
      );
  };
}
