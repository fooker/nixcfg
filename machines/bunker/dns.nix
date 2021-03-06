{ config, lib, pkgs, path, ... }:

with lib;

let
  mkDynZone = domain: pkgs.writeText "${domain}.zone" ''
    $ORIGIN ${domain}.
    $TTL 60

    @ SOA	ns.inwx.de. hostmaster.inwx.de. (
        2021011300
        200
        300
        1814400
        300 )

      NS	ns.inwx.de.
      NS	ns2.inwx.de.
      NS	ns3.inwx.eu.
  '';

in {
  /* Let systemd-resolved not listen on 127.0.0.53:53 to avoid conflicts with
     kresd listening on wildcard.
  */
  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

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
          journal-content: changes

      zone:
        - domain: "dyn.open-desk.net"
          notify: inwx
          acl: [ inwx_transfer, acme_update ]
          file: "${ mkDynZone "dyn.open-desk.net" }"

        - domain: "frisch.cloud"
          notify: inwx
          acl: [ inwx_transfer ]
          file: "${ ./zones/frisch.cloud }"
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
}
