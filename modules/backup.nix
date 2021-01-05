{ config, lib, pkgs, path, ... }:

with lib;
{
  options.backup = {
    enable = mkOption {
        type = types.bool;
        default = false;
    };

    repo = {
      user = mkOption {
        type = types.str;
        description = ''
          User with which to store the backup.
        '';
        default = "backup";
      };

      host = mkOption {
        type = types.str;
        description = ''
          Host on which to store the backup.
        '';
        default = "backup.home.open-desk.net";
      };

      fingerprint = mkOption {
        type = types.str;
        description = ''
          SSH fingerprint of the backup storage host.
        '';
        default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ58kj0PhHZThJ00tXLwNCFfK8o4RArFcNqtWfaXWto3";
      };
    };

    passphrase = mkOption {
      type = types.str;
      description = ''
        The passphrase the backups are encrypted with
      '';
    };

    paths = mkOption {
      type = with types; coercedTo str lib.singleton (listOf str);
      description = ''
        Path(s) to back up.
      '';
      default = [];
    };

    commands = mkOption {
      type = with types; coercedTo str lib.singleton (listOf str);
      description = ''
        Command(s) to include into backup.
      '';
      default = [];
    };

    defaultPaths = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.backup.enable {
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
        passphrase = config.backup.passphrase;
      };

      environment = {
        "BORG_RSH" = "ssh -i /var/lib/backup/id_backup";
      };

      paths = concatLists [
        config.backup.paths
        (singleton ".")
        (optionals config.backup.defaultPaths [ "/etc" "/root" ])
      ];

      readWritePaths = [ "/tmp" ];

      preHook = ''
        mkdir /tmp/backup-$archiveName
        cd /tmp/backup-$archiveName

        ${concatMapStringsSep "\n" (command: "${command}") config.backup.commands}
      '';
    };

    deployment.secrets = {
      "backup-sshkey" = rec {
        source = "${path}/secrets/id_backup";
        destination = "/var/lib/backup/id_backup";
        owner.user = "root";
        owner.group = "root";
        action = [ ''
          ${pkgs.openssh}/bin/ssh-keygen -y -f ${destination} > ${destination}.pub
        '' ];
      };
    };
  };
}
