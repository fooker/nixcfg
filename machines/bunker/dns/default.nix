{ config, lib, pkgs, path, inputs, nodes, ... }:

with lib;

let
  generator = pkgs.callPackage inputs.dns.generator {
    configs = mapAttrsToList (_: node: node.config) nodes;
  };

  zones = map
    (zone: {
      inherit (zone) name;

      notify = "inwx";
      acl = [ "inwx_transfer" ] ++ optional ((last zone.name.labels) == "dyn") "acme_update";

      file = zone.zoneFile;
    })
    generator.zones;

in
{
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
      })
      zones);

    systemd.services.knot.restartTriggers = map
      (zone: zone.file)
      zones;

    services.knot = {
      enable = true;

      keyFiles = [
        config.sops.secrets."knot/acme/update".path
      ];

      settings = {
        server = {
          listen = [ "0.0.0.0@53" "::@53" ];
        };

        remote = [
          {
            id = "inwx";
            address = [ "185.181.104.96@53" "2a0a:c980::53@53" ];
          }
        ];

        acl = [
          {
            id = "inwx_transfer";
            address = [ "185.181.104.96" "2a0a:c980::53" ];
            action = "transfer";
          }

          {
            id = "acme_update";
            address = [ "127.0.0.1" "::1" "172.23.200.0/24" "fd79:300d:6056::/48" ];
            action = "update";
            update-type = "TXT";
            key = [ "acme_update" ];
          }
        ];

        policy = [
          {
            id = "default";
            algorithm = "ed25519";
            cds-cdnskey-publish = "always";
          }
        ];

        template = [
          {
            id = "default";
            semantic-checks = true;
            zonefile-sync = -1;
            zonefile-load = "difference-no-serial";
            serial-policy = "dateserial";
            journal-content = "all";
            dnssec-signing = "on";
            dnssec-policy = "default";
          }
        ];

        zone = map
          (zone: {
            inherit (zone) notify acl;
            domain = zone.name.toSimpleString;
            file = "/etc/knot/zones/${ zone.name.toSimpleString }.zone";
          })
          zones;
      };
    };

    firewall.rules = dag: with dag; {
      inet.filter.input = {
        dns = between [ "established" ] [ "drop" ] [
          "udp dport 53 accept"
          "tcp dport 53 accept"
        ];
      };
    };

    backup.commands = [
      ''
        mkdir knot
        ${ pkgs.lmdb }/bin/mdb_dump '/var/lib/knot/journal' -f knot/journal.dump
        ${ pkgs.lmdb }/bin/mdb_dump '/var/lib/knot/timers'  -f knot/timers.dump
        ${ pkgs.lmdb }/bin/mdb_dump '/var/lib/knot/keys'    -f knot/keys.dump    -a
      ''
    ];

    backup.paths = [
      "/var/lib/knot"
    ];

    sops.secrets."knot/acme/update" = {
      format = "binary";
      sopsFile = ../secrets/knot-key-acme-update.incl;
      owner = "knot";
    };

    monitoring.services = map
      (zone: {
        name = "DNS:${zone.name.toSimpleString}";
        interfaces = "ext";
      })
      zones;
  };
}
