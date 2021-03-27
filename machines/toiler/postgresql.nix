{ pkgs, lib, ... }:

with lib;

{
  services.postgresql = {
    enable = true;
    package = mkForce pkgs.postgresql_12;
  };

  backup = {
    commands = map
      (database: ''${ config.services.postgresql.package }/bin/pg_dump --format tar --file postgres-${ database }.tar ${ database }'')
      config.services.postgresql.ensureDatabases;
  };
}
