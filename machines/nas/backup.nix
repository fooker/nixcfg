{ config, lib, pkgs, nodes, ... }:

with lib;

let
  secrets = import ./secrets.nix;

in {
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
        };
      });
      description = "The backup repositories to provide";
    };
  };

  config = {
    services.borgbackup.repos = listToAttrs (map
      (repo: nameValuePair repo.name {
        path = "/mnt/backups/borg/${ repo.name }";

        authorizedKeysAppendOnly = [ "${ repo.publicKey } ${ repo.name }" ];

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

    backup.server.repos =
      # Create repos for all defined nodes
      (mapAttrsToList
        (name: node: {
          inherit name;
          publicKey = node.config.backup.publicKey;
        })
        nodes)

      # Legacy repos
      ++ secrets.backup.server.repos;
  };
}