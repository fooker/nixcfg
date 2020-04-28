{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  services.borgbackup.repos = builtins.mapAttrs (name: key: {
    path = "/mnt/backups/borg/${ name }";

    authorizedKeysAppendOnly = [ "${ key } ${ name }" ];
    
    allowSubRepos = true;
    
    user = "backup";
    group = "backup";
  }) secrets.backup.repos;
}