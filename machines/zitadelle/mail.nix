{ config, lib, pkgs, inputs, ... }:

with lib;

let
  secrets = import ./secrets.nix;
in
{
  imports = [
    (import inputs.nixos-mailserver)
  ];

  mailserver = {
    enable = true;
    debug = true;

    fqdn = config.dns.host.domain.toSimpleString;

    domains = [
      "open-desk.net"
      "open-desk.org"
      "lab.sh"
      "schoen-und-gut.org"
    ];

    loginAccounts = secrets.mail.accounts;

    extraVirtualAliases =
      let
        aliases = [
          "root"
          "webmaster"
          "hostmaster"
          "postmaster"
          "operator"
          "abuse"
          "security"
        ];
      in
      listToAttrs
        (concatMap
          (domain: map
            (alias: nameValuePair "${ alias }@${ domain }" "root@open-desk.net")
            aliases)
          config.mailserver.domains);

    forwards = secrets.mail.forwards;

    enableSubmission = true;
    enableSubmissionSsl = true;
    enableImap = true;
    enablePop3 = false;
    enableImapSsl = true;
    enablePop3Ssl = false;

    enableManageSieve = true;

    virusScanning = true;

    certificateScheme = 1; # Manual certificate management
    certificateFile = config.letsencrypt.certs.mail.path.cert;
    keyFile = config.letsencrypt.certs.mail.path.key;

    dkimSigning = true;
    dkimKeyDirectory = "/etc/secrets/dkim";
    dkimSelector = "mail";

    mailDirectory = "/data/mail";
  };

  services.dovecot2.mailPlugins.globally.enable = [ "zlib" "notify" "replication" ];
  services.dovecot2.extraConfig = ''
    service replicator {
      process_min_avail = 1

      unix_listener replicator-doveadm {
        user = ${ config.mailserver.vmailUserName }
        group = ${ config.mailserver.vmailGroupName }
        mode = 0660
      }
    }

    service aggregator {
      fifo_listener replication-notify-fifo {
        user = ${ config.mailserver.vmailUserName }
        group = ${ config.mailserver.vmailGroupName }
        mode = 0660
      }
      unix_listener replication-notify {
        user = ${ config.mailserver.vmailUserName }
        group = ${ config.mailserver.vmailGroupName }
        mode = 0660
      }
    }

    service doveadm {
      inet_listener {
        address = '${ config.hive.self.address.ipv6 }'
        port = 22025
      }
    }

    replication_max_conns = 10

    doveadm_port = 22025
    doveadm_password = '${ secrets.dovecot.doveadm.password }'

    plugin {
      mail_replica = tcp:[${ config.hive.spouse.address.ipv6 }]:22025
    }
  '';

  letsencrypt.certs.mail = {
    domains = flatten ([
      "mx.open-desk.net"
      (concatMap
        (domain: [
          "mail.${ domain }"
          "smtp.${ domain }"
          "imap.${ domain }"
        ])
        config.mailserver.domains)
      config.mailserver.fqdn
    ]);
    owner = "root";
    trigger = ''
      ${pkgs.systemd}/bin/systemctl reload dovecot2.service
      ${pkgs.systemd}/bin/systemctl reload postfix.service
    '';
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      mail = between [ "established" ] [ "drop" ] ''
        tcp dport 25
        accept
      '';
      mail-submission = between [ "established" ] [ "drop" ] ''
        tcp dport { 587, 465 }
        accept
      '';
      mail-imap = between [ "established" ] [ "drop" ] ''
        tcp dport { 143, 993 }
        accept
      '';
      mail-sieve = between [ "established" ] [ "drop" ] ''
        tcp dport 4190
        accept
      '';
      mail-replicate = between [ "established" ] [ "drop" ] ''
        ip6 saddr ${ config.hive.spouse.address.ipv6 }
        tcp dport 22025
        accept
      '';
    };
  };

  dns.zones =
    let
      mx = {
        A = config.dns.host.ipv4;
        AAAA = config.dns.host.ipv6;
      };
    in
    mkMerge [
      {
        net.open-desk.mx = mx;
      }

      # MX and related security and service records for all domains we serve for
      (mkMerge (map
        (domain: (mkDomainAbsolute domain).mkRecords {

          # MX record for this server
          MX = {
            preference = 0;
            exchange = mkDomainAbsolute config.mailserver.fqdn;
          };

          # SPF record
          TXT = "v=spf1 mx -all";

          # DKIM record
          includes = [ (./secrets/dkim/. + "/${ domain }.mail.txt") ];

          # DMARK record
          _dmarc = {
            TXT = "v=DMARC1; p=none; rua=mailto:postmaster@open-desk.net; ruf=mailto:postmaster@open-desk.net; sp=none; fo=1; aspf=s; adkim=s; ri=86400";
          };

          # Host records for the related services
          mail = mx;
          smtp = mx;
          imap = mx;
        })
        config.mailserver.domains))
    ];

  backup.paths = [
    "/data/mail"
    "/var/sieve"
  ];

  deployment.keys = listToAttrs (concatMap
    (domain: [
      (nameValuePair "dkim-mail-${ domain }-key" {
        keyFile = toString ./secrets/dkim + "/${ domain }.mail.key";
        destDir = config.mailserver.dkimKeyDirectory;
        user = config.services.opendkim.user;
        group = config.services.opendkim.group;
      })
      (nameValuePair "dkim-mail-${ domain }-txt" {
        keyFile = toString ./secrets/dkim + "/${ domain }.mail.txt";
        destDir = config.mailserver.dkimKeyDirectory;
        user = config.services.opendkim.user;
        group = config.services.opendkim.group;
      })
    ])
    config.mailserver.domains
  );

  systemd.service."opendkim" = mkMerge (map
    (domain: {
      requires = [ "dkim-mail-${domain}-key.service" ];
      bindsTo = [ "dkim-mail-${domain}-key.service" ];
      partOf = [ "dkim-mail-${domain}-key.service" ];
    })
    config.mailserver.domains);
}
