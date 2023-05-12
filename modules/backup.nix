{ config, lib, pkgs, path, name, ... }:

with lib;
{
  options.backup = {
    repo = {
      user = mkOption {
        type = types.str;
        description = ''
          User with which to store the backup.
        '';
      };

      host = mkOption {
        type = types.str;
        description = ''
          Host on which to store the backup.
        '';
      };

      fingerprint = mkOption {
        type = types.str;
        description = ''
          SSH fingerprint of the backup storage host.
        '';
      };
    };

    publicKey = mkOption {
      type = types.str;
      description = ''
        Public SSH key used by the backup client.
      '';
    };

    extraPublicKeys = mkOption {
      type = types.attrsOf types.str;
      description = ''
        Additional public SSH keys.
      '';
      default = { };
    };

    passphrase = mkOption {
      type = types.str;
      description = ''
        The passphrase the backups are encrypted with.
      '';
    };

    paths = mkOption {
      type = with types; coercedTo str lib.singleton (listOf str);
      description = ''
        Path(s) to back up.
      '';
      default = [ ];
    };

    commands = mkOption {
      type = with types; coercedTo str lib.singleton (listOf str);
      description = ''
        Command(s) to include into backup.
      '';
      default = [ ];
    };

    defaultPaths = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config =
    let
      # Create a standalone bash script for each command
      scripts = map
        (pkgs.writeShellScript "backup-script")
        config.backup.commands;

    in
    {
      services.openssh.knownHosts.backup = {
        hostNames = [ config.backup.repo.host ];
        publicKey = config.backup.repo.fingerprint;
      };

      services.borgbackup.jobs.system = {
        repo = with config.backup.repo; "${user}@${host}:system";

        doInit = true;

        archiveBaseName = "system";
        dateFormat = "+%Y-%m-%dT%H:%M";

        encryption = {
          mode = "repokey";
          inherit (config.backup) passphrase;
        };

        environment = {
          "BORG_RSH" = "ssh -i /var/lib/backup/id_backup";
        };

        paths = config.backup.paths ++ [ "." ];

        readWritePaths = [ "/tmp" ];

        preHook = ''
          mkdir /tmp/backup-$archiveName
          cd /tmp/backup-$archiveName

          ${concatStringsSep "\n" scripts}
        '';
      };

      backup.paths = [ "/etc" "/root" ];

      backup.publicKey = mkDefault (fileContents "${path}/gathered/id_backup.pub");

      system.activationScripts."backup-sshkey" = ''
        if ! [ -f "/var/lib/backup/id_backup" ]; then
          mkdir -pv /var/lib/backup
          ${pkgs.openssh}/bin/ssh-keygen \
            -N "" \
            -t ed25519 \
            -f /var/lib/backup/id_backup \
            -C "backup@${name}"
        fi
      '';

      gather = {
        "id_backup.pub" = {
          file = "/var/lib/backup/id_backup.pub";
        };
      };
    };
}
