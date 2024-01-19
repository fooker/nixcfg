{ config, lib, pkgs, inputs, private, ... }:

with lib;

{
  imports = [
    (import inputs.nixos-mailserver)
  ];

  mailserver = {
    enable = true;

    fqdn = config.dns.host.domain.toSimpleString;

    domains = [
      "open-desk.net"
      "open-desk.org"
      "lab.sh"
      "schoen-und-gut.org"
    ];

    loginAccounts = private.mail.accounts;

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

    inherit (private.mail) forwards;

    enableSubmission = true;
    enableSubmissionSsl = true;
    enableImap = true;
    enablePop3 = false;
    enableImapSsl = true;
    enablePop3Ssl = false;

    enableManageSieve = true;

    virusScanning = true;

    certificateScheme = "manual";
    certificateFile = config.letsencrypt.certs.mail.path.cert;
    keyFile = config.letsencrypt.certs.mail.path.key;

    dkimSigning = true;
    dkimKeyDirectory = "/etc/secrets/dkim";
    dkimSelector = "mail";

    mailDirectory = "/data/mail";

    redis = {
      address = "127.0.0.1";
      port = 6379;
    };
  };

  # Disable default redis impl as we use keydb server
  services.redis.servers.rspamd.enable = mkForce false;
  systemd.services.keydb = {
    aliases = [
      "redis-rspamd.service"
    ];
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
    doveadm_password = <${config.sops.secrets."mail/doveadm/password".path}

    plugin {
      mail_replica = tcp:[${ config.hive.spouse.address.ipv6 }]:22025
    }
  '';

  letsencrypt.certs.mail = {
    domains = flatten [
      "mx.open-desk.net"
      (concatMap
        (domain: [
          "mail.${ domain }"
          "smtp.${ domain }"
          "imap.${ domain }"
        ])
        config.mailserver.domains)
      config.mailserver.fqdn
    ];
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
          TXT = "v=spf1 mx a:mail.${domain} a:smtp:${domain} a:mail.open-desk.net -all";

          # DKIM record
          # TODO: Use a selector per server?
          includes = [ ./secrets/dkim/${"${domain}.mail.txt"} ];
          # _domainkey.mail = {
          #   TXT = "v=DKIM1; k=rsa; p=${fileContents config.gathered.parts."dkim/${domain}/mail".path}";
          # };

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

  sops.secrets = (listToAttrs (concatMap
    (domain: [
      (nameValuePair "dkim/${domain}/mail" {
        format = "binary";
        sopsFile = ./secrets/dkim + "/${domain}.mail.key";
        path = "/etc/secrets/dkim/${domain}.mail.key";
        owner = "opendkim";
      })
    ])
    config.mailserver.domains
  )) // {
    "mail/doveadm/password" = {
      sopsFile = ./secrets.yaml;
    };
  };

  gather.parts = listToAttrs (map
    (domain: nameValuePair "dkim/${domain}/mail" {
      name = "dkim/${domain}.mail.pub";
      command = ''
        ${pkgs.openssl}/bin/openssl rsa -in ${config.sops.secrets."dkim/${domain}/mail".path} -pubout -outform PEM | head -n -1 | tail -n +2
      '';
    })
    config.mailserver.domains);
}
