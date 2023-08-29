{ pkgs, config, lib, nodes, ... }:

with lib;

{
  options = {
    backup.server.repos = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name of the repository";
          };
          publicKey = mkOption {
            type = types.str;
            description = "Public SSH key of the client using this repository";
          };
          extraPublicKeys = mkOption {
            type = types.attrsOf types.str;
            description = "Additional public SSH keys";
            default = { };
          };
        };
      });
      description = "The backup repositories to provide";
    };
  };

  config = {
    services.borgbackup.repos = listToAttrs (map
      (repo: nameValuePair repo.name {
        path = "/mnt/backups/borg/${ repo.name }";

        authorizedKeysAppendOnly = [ "${ repo.publicKey } ${ repo.name }" ]
          ++ mapAttrsToList
          (desc: publicKey: "${publicKey} ${repo.name}/${desc}")
          repo.extraPublicKeys;

        allowSubRepos = true;

        user = "backup";
        group = "backup";
      })
      config.backup.server.repos);

    dns.zones = {
      net.open-desk.home.backup = {
        CNAME = config.dns.host.domain;
      };
    };

    # Create repos for all defined nodes
    backup.server.repos = mapAttrsToList
      (name: node: {
        inherit name;
        inherit (node.config.backup) publicKey extraPublicKeys;
      })
      nodes;
    
    systemd.services.backup-opennms-repos = {
      startAt = "3/4:00:00";
      script = ''
        mkdir -p /mnt/backups/opennms
        cd /mnt/backups/opennms

        exec ${./backup-opennms-repos.sh}
      '';

      path = with pkgs; [ bash git curl jq ];
    };
  };
}
