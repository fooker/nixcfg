{ lib, pkgs, config, ... }:

with lib;

let
  keydb = pkgs.callPackage ../../packages/keydb { };

  port = 6379;

  configFile = pkgs.writeText "keydb-config.yaml" ''
    port ${toString port}

    bind 127.0.0.1 ::1 ${toString config.hive.self.address.ipv4} ${toString config.hive.self.address.ipv6}

    dir /var/lib/keydb

    save 900 1
    save 300 10
    save 60 10000

    active-replica yes
    multi-master yes
    
    ${
      # Replication config lines for all other nodes in the hive
      concatMapStringsSep "\n"
        (node: "replicaof ${toString node.address.ipv4} ${toString port}")
        (attrValues config.hive.others)
    }
  '';

in
{
  options.hive.keydb = {
    enable = mkOption {
      type = types.bool;
      description = "keydb/redis node";
      default = true;
    };
  };

  config = mkIf (config.hive.enable && config.hive.keydb.enable) {
    systemd.services.keydb = {
      description = "KeyDB";

      aliases = [
        "redis.service"
      ];

      unitConfig = {
        StartLimitIntervalSec = 60;
      };

      serviceConfig = {
        Type = "notify";

        ExecStart = "${keydb}/bin/keydb-server ${configFile} --supervised systemd";

        RuntimeDirectory = "keydb";
        StateDirectory = "keydb";

        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_SYS_RESOURCE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_SYS_RESOURCE" ];
        DevicePolicy = "closed";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6 AF_UNIX" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" "~@privileged @resources" ];
        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
    };

    firewall.rules =
      let
        nodes = concatMapStringsSep "," (node: node.address.ipv4) (attrValues config.hive.nodes);
      in
      dag: with dag; {
        inet.filter.input = {
          keydb-replication = between [ "established" ] [ "drop" ] ''
            ip saddr { ${nodes} } tcp dport ${toString port} accept
          '';
        };
      };
  };
}
