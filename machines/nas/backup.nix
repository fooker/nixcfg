{ pkgs, config, lib, nodes, private, ... }:

with lib;

{
  options = {
    backup.server.repos = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name of the repository";
            default = name;
            readOnly = true;
          };
          publicKey = mkOption {
            type = types.str;
            description = "Public SSH key of the client using this repository";
          };
        };
      }));
      description = "The backup repositories to provide";
    };
  };

  config = {
    services.borgbackup.repos = mapAttrs'
      (_: repo: nameValuePair (replaceStrings [ "/" ] [ "-" ] repo.name) {
        path = "/mnt/backups/borg/${repo.name}";

        authorizedKeysAppendOnly = [
          "${repo.publicKey} ${repo.name}"
        ];

        allowSubRepos = true;

        user = "backup";
        group = "backup";
      })
      config.backup.server.repos;

    dns.zones = {
      net.open-desk.home.backup = {
        CNAME = config.dns.host.domain;
      };
    };

    backup.server.repos = mkMerge [
      # Create repos for all nodes having jobs with target "default"
      (mapAttrs
        (name: node: {
          publicKey = fileContents node.config.gather.parts."backup/sshKey".path;
        })
        (filterAttrs
          (name: node: any
            (job: elem "default" (map (target: target.name) job.targets))
            (attrValues node.config.backup.jobs))
          nodes))
      private.backup.repos
    ];

    systemd.services.backup-opennms-repos = {
      startAt = "3/4:00:00";
      script = ''
        mkdir -p /mnt/backups/opennms
        cd /mnt/backups/opennms

        exec ${./backup-opennms-repos.sh}
      '';

      path = with pkgs; [ bash git curl jq ];
    };

    users = {
      users."backup" = {
        isSystemUser = true;
        group = "backup";
      };
      groups."backup" = { };
    };
  };
}
