{ pkgs, lib, config, ... }:

with lib;

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
  };

  backup = {
    commands = map
      (database: ''${pkgs.su}/bin/su postgres -c "${config.services.postgresql.package}/bin/pg_dump --format tar ${database}" > postgres-${database}.tar'')
      config.services.postgresql.ensureDatabases;
  };
}
