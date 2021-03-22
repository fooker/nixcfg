{ config, lib, pkgs, path, ... }:

with lib;

let
  zones = let
    mkRecord = { domain, ttl, type, class, data }: concatStringsSep " " ([
      (toString domain)
      (toString ttl)
      class
      type
    ] ++ data);

    mkInclude = { domain, file }: "$INCLUDE \"${ file }\" ${ domain.toString }";

  in map
    (zone: {
      inherit (zone) name;

      notify = "inwx";
      acl = [ "inwx_transfer" ] ++ optional ((last zone.name.labels) == "dyn") "acme_update";

      file = pkgs.writeText "${ zone.name.toSimpleString }.zone" ''
          ${ concatMapStringsSep "\n" mkRecord zone.records }
          ${ concatMapStringsSep "\n" mkInclude zone.includes }
        '';
    })
    config.dns.zoneList;

in {
  imports = [
    ./zones.nix
  ];
  
  config = {
    /* Let systemd-resolved not listen on 127.0.0.53:53 to avoid conflicts with
      kresd listening on wildcard.
    */
    services.resolved.extraConfig = ''
      DNSStubListener=no
    '';

    # Use stable paths for zone files so there are less config changes to knot
    environment.etc = listToAttrs (map
      (zone: nameValuePair "knot-zone-${ zone.name.toSimpleString }" {
        target = "knot/zones/${ zone.name.toSimpleString }.zone";
        source = zone.file;
      }) zones);

    systemd.services.knot.restartTriggers = map
      (zone: zone.file)
      zones;

    services.knot = {
      enable = true;

      keyFiles = [
        config.deployment.secrets."knot-key-acme-update".destination
      ];

      extraConfig = ''
        server:
          listen: [ "0.0.0.0@53", "::@53" ]

        remote:
          - id: "inwx"
            address: [ "185.181.104.96@53", "2a0a:c980::53@53" ]

        acl:
          - id: inwx_transfer
            address: [ "185.181.104.96", "2a0a:c980::53" ]
            action: transfer

          - id: acme_update
            address: [ "127.0.0.1", "::1", "172.23.200.0/24", "fd79:300d:6056::/48" ]
            action: update
            update-type: TXT
            key: [ acme_update ]

        template:
          - id: default
            semantic-checks: true
            zonefile-sync: -1
            zonefile-load: difference-no-serial
            serial-policy: dateserial
            journal-content: all

        zone:
        ${ concatMapStringsSep "\n" (zone: ''
          - domain: "${ zone.name.toSimpleString }"
            notify: ${ zone.notify }
            acl: [ ${ concatStringsSep ", " zone.acl } ]
            file: "/etc/knot/zones/${ zone.name.toSimpleString }.zone"
        '') zones }
      '';
    };

    firewall.rules = dag: with dag; {
      inet.filter.input = {
        dns-udp = between ["established"] ["drop"] ''
          udp dport 53
          accept
        '';
        dns-tcp = between ["established"] ["drop"] ''
          tcp dport 53
          accept
        '';
      };
    };

    deployment.secrets = {
      "knot-key-acme-update" = {
        source = "${path}/secrets/knot-key-acme-update.incl";
        destination = "/var/lib/knot/key-acme-update.incl";
        owner.user = "knot";
        owner.group = "knot";
      };
    };
  };
}
