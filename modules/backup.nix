{ config, lib, pkgs, path, ... }:

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
        Publick SSH key used by the backup client.
      '';
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

  config = let
    # Create a standalone bash script for each command
    scripts = map
      (command: pkgs.writeShellScript "backup-script" command)
      config.backup.commands;

  in {
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

      paths = config.backup.paths ++ [ "." ];

      readWritePaths = [ "/tmp" ];

      preHook = ''
        mkdir /tmp/backup-$archiveName
        cd /tmp/backup-$archiveName

        ${concatStringsSep "\n" scripts}
      '';
    };

    backup.paths = [ "/etc" "/root" "/home" ];

    backup.publicKey = mkDefault (builtins.readFile "${path}/secrets/id_backup.pub");

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
