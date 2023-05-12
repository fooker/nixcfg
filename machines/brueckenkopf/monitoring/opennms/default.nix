{ config, pkgs, lib, ... }:

with lib;

let
  jicmp = pkgs.callPackage ../../../../packages/opennms/jicmp { };
  jicmp6 = pkgs.callPackage ../../../../packages/opennms/jicmp6 { };
  jrrd2 = pkgs.callPackage ../../../../packages/opennms/jrrd2 { };

  opennms = pkgs.callPackage ../../../../packages/opennms/opennms.nix { };
in
{
  imports = [
    ./requisition.nix
  ];

  users = {
    users."opennms" = {
      home = "/var/lib/opennms";
      createHome = true;
      isSystemUser = true;
      group = "opennms";
    };
    groups."opennms" = { };
  };

  systemd.tmpfiles.rules = [
    "d '/var/lib/opennms' - opennms opennms - -"
    "d '/var/lib/opennms/data' - opennms opennms - -"
    "d '/var/log/opennms' - opennms opennms - -"
    "d '/etc/opennms' - opennms opennms - -"
  ];

  systemd.services."opennms" = {
    description = "OpenNMS Horizon";
    after = [ "network.target" "systemd-tmpfiles-setup.service" ];

    path = with pkgs; [
      bash
      rrdtool
    ];

    serviceConfig = {
      # User = "opennms";
      # Group = "opennms";

      Type = "forking";

      ExecStartPre = [
        "/opt/opennms/bin/runjava -S ${pkgs.openjdk11}/bin/java"
        "/opt/opennms/bin/install -dis --library-path ${jicmp}/lib:${jicmp6}/lib:${jrrd2}/lib"
      ];

      ExecStart = "/opt/opennms/bin/opennms -s start";
      ExecStop = "/opt/opennms/bin/opennms stop";

      RuntimeDirectory = "opennms";

      PIDFile = "/var/log/opennms/opennms.pid";
      TimeoutStartSec = "10m";

      BindReadOnlyPaths = [
        "${opennms.horizon}/opt/opennms:/opt/opennms"
      ];

      BindPaths = [
        "/etc/opennms:/opt/opennms/etc"
        "/var/lib/opennms:/opt/opennms/share"
        "/var/log/opennms:/opt/opennms/logs"
      ];

      TemporaryFileSystem = [
        "/opt/opennms/data"
      ];

      # AmbientCapabilities = "cap_net_bind_service";
      # CapabilityBoundingSet = "cap_net_bind_service";

      # NoNewPrivileges = true;
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_12.withPackages (_: [
      (pkgs.callPackage ../../../../packages/opennms/iplike { postgresql = pkgs.postgresql_12; })
    ]);
  };

  web.reverse-proxy = {
    "opennms" = {
      domains = [ "opennms.open-desk.net" ];
      target = "http://127.0.0.1:8980";
    };
  };

  programs.ssh.extraConfig = ''
    Host opennms
      Port 8101
      User admin
      HostName 127.0.0.1
      CheckHostIP no
      NoHostAuthenticationForLocalhost yes
      SetEnv TERM=xterm
      StrictHostKeyChecking no
  '';

  backup = {
    commands = ''${pkgs.su}/bin/su postgres -c "${config.services.postgresql.package}/bin/pg_dump --format tar opennms" > ./postgres-opennms.tar'';
    paths = [
      "/etc/opennms"
      "/var/lib/opennms"
    ];
  };
}
