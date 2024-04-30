{ config, lib, pkgs, path, name, ... }:

with lib;
{
  options.backup = {
    targets = mkOption {
      type = types.attrsOf (types.fnOf (types.fnOf (types.submodule ({ name, ... }: {
        options = {
          name = mkOption {
            type = types.str;
            description = ''
              Name of the target.
            '';
            default = name;
            readOnly = true;
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

          user = mkOption {
            type = types.str;
            description = ''
              User with which to store the backup.
            '';
          };

          path = mkOption {
            type = types.str;
            description = ''
              Path of the repository
            '';
          };
        };
      }))));
      default = { };
    };

    jobs = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          name = mkOption {
            type = types.str;
            description = ''
              Name of the job.
            '';
            default = name;
            readOnly = true;
          };

          targets = mkOption {
            type = types.listOf
              (types.coercedTo
                (types.types.enum (attrNames config.backup.targets))
                (name: { inherit name; options = { }; })
                (types.submodule {
                  options = {
                    name = mkOption {
                      type = types.types.enum (attrNames config.backup.targets);
                      description = ''
                        Name of the target
                      '';
                    };

                    options = mkOption {
                      type = types.anything;
                      description = ''
                        Target-specific options
                      '';
                    };
                  };
                }));
            description = ''
              Target backup servers to create a backup on.
            '';
            default = [ "default" ];
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
        };
      }));
      default = { };
    };
  };

  config = {
    services.borgbackup.jobs = listToAttrs (concatLists (mapAttrsToList
      (_: job: map
        (target: nameValuePair "${job.name}-${target.name}" (
          let
            target' = config.backup.targets.${target.name} job target.options;
            #(target.options // {
            #  inherit job;
            #});

            known-hosts = pkgs.writeText "known_hosts" ''
              ${target'.host} ${target'.fingerprint}
            '';
          in
          {
            repo = "${target'.user}@${target'.host}:${target'.path}";

            doInit = true;

            archiveBaseName = "${name}-${job.name}";
            dateFormat = "+%Y-%m-%dT%H:%M";

            encryption = {
              mode = "repokey";
              passCommand = ''cat ${config.sops.secrets."backup/passphrase".path}'';
            };

            environment = {
              "BORG_RSH" = "ssh -i /var/lib/backup/id_backup -o UserKnownHostsFile=${known-hosts} -o StrictHostKeyChecking=yes";
            };

            paths = job.paths ++ [ "." ];

            readWritePaths = [ "/tmp" ];

            preHook = ''
              mkdir /tmp/backup-$archiveName
              cd /tmp/backup-$archiveName
  
              ${concatMapStringsSep "\n" (pkgs.writeShellScript "backup-script") job.commands}
            '';
          }
        ))
        job.targets)
      config.backup.jobs));

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

    sops.secrets."backup/passphrase" = {
      sopsFile = "${path}/secrets.yaml";
    };

    gather.parts = {
      "backup/sshKey" = {
        name = "id_backup.pub";
        file = "/var/lib/backup/id_backup.pub";
      };
    };
  };
}
