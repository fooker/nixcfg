{ config, lib, pkgs, ... }:

with lib;
{
  options.backup = {
    enable = mkOption {
        type = types.bool;
        default = false;
    };

    target = mkOption {
      type = types.str;
      description = ''
        Host on which to store the backup.
      '';
      default = "backup@backup.home.open-desk.net";
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
    services.borgbackup.jobs.system = {
      repo = "${config.backup.target}:";

      archiveBaseName = "system";
      dateFormat = "+%Y-%m-%dT%H:%M";

      encryption = {
        mode = "repokey";
        passphrase = config.backup.passphrase;
      };

      environment = {
        # "BORG_RSH" = "ssh -i /var/lib/backup/id_ed25519 -o UserKnownHostsFile=/var/lib/backup/known_hosts";
      };

      paths = concatLists [
        config.backup.paths
        (singleton ".")
        (optionals config.backup.defaultPaths [ "/root" "/home" ])
      ];

      preHook = concatMapStringsSep "\n" (command: "${escapeShellArgs command}") config.backup.commands;
    };
  };
}
