{ config, lib, pkgs, ... }:

with lib;

{
  options.hive.mariadb = {
    enable = mkOption {
      type = types.bool;
      description = "mariadb/galera node";
      default = true;
    };
  };

  config = mkIf (config.hive.enable && config.hive.mariadb.enable) {
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;

      settings = {
        galera = {
          wsrep_on = "ON";
          wsrep_debug = "NONE";
          wsrep_retry_autocommit = "3";
          wsrep_provider = "${pkgs.mariadb-galera}/lib/galera/libgalera_smm.so";
          wsrep_cluster_address = "gcomm://${ concatMapStringsSep "," (node: toString node.address.ipv4) (attrValues config.hive.others) }";
          wsrep_cluster_name = "open-desk";
          wsrep_node_address = toString config.hive.self.address.ipv4;
          wsrep_node_name = config.hive.self.id;
          wsrep_sst_method = "rsync";

          binlog_format = "ROW";
          enforce_storage_engine = "InnoDB";
          innodb_autoinc_lock_mode = "2";
        };
      };
    };

    systemd.services.mysql = {
      path = with pkgs; [
        bash
        gawk
        gnutar
        inetutils
        which
        lsof
        procps
        rsync
        stunnel
      ];

      serviceConfig.TimeoutStartSec = "1h";
    };

    firewall.rules =
      let
        nodes = concatMapStringsSep "," (node: node.address.ipv4) (attrValues config.hive.nodes);
      in
      dag: with dag; {
        inet.filter.input = {
          mysql-client = between [ "established" ] [ "drop" ] ''
            ip saddr { ${nodes} }
            tcp dport 3306
            accept
          '';

          mysql-replication = between [ "established" ] [ "drop" ] [
            ''ip saddr { ${nodes} } tcp dport { 4567, 4568, 4444 } accept''
            ''ip saddr { ${nodes} } udp dport { 4567 }             accept''
          ];
        };
      };

    backup.commands = [
      "${pkgs.mariadb}/bin/mariabackup --backup --target-dir=./mariadb --user=root"
    ];
  };
}
