{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  systemd.services.drone-server = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment = [
        "DRONE_DATABASE_DATASOURCE=postgres:///drone?host=/run/postgresql"
        "DRONE_DATABASE_DRIVER=postgres"
        "DRONE_GITEA_SERVER=https://git.home.open-desk.net"
        "DRONE_GITEA_CLIENT_ID=${secrets.drone.gitea.client_id}"
        "DRONE_GITEA_CLIENT_SECRET=${secrets.drone.gitea.client_secret}"
        "DRONE_DATABASE_SECRET=${secrets.drone.db.secret}"
        "DRONE_RPC_SECRET=${secrets.drone.rpc.secret}"
        "DRONE_SERVER_HOST=ci.home.open-desk.net"
        "DRONE_SERVER_PORT=:3030"
        "DRONE_SERVER_PROTO=https"
      ];
      ExecStart = "${pkgs.drone}/bin/drone-server";
      User = "drone";
      Group = "drone";
    };
  };

  systemd.services.drone-agent = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment = [
        "DRONE_RPC_HOST=ci.home.open-desk.net"
        "DRONE_RPC_PROTO=https"
        "DRONE_RPC_SECRET=${secrets.drone.rpc.secret}"
        "DRONE_RUNNER_CAPACITY=10"
        "DRONE_RUNNER_NAME=${config.networking.hostName}"
      ];
      ExecStart = "${pkgs.drone}/bin/drone-agent";
      User = "drone-agent";
      Group = "drone-agent";
      SupplementaryGroups = [ "docker" ];
      DynamicUser = true;
    };
  };

  virtualisation.docker = {
    enable = true;
  };
  environment.systemPackages = [ pkgs.drone ];

  services.postgresql = {
    ensureDatabases = [ "drone" ];
    ensureUsers = [ {
      name = "drone";
      ensurePermissions = {
        "DATABASE drone" = "ALL PRIVILEGES";
      };
    } ];
  };

  users = {
    users."drone" = {
      isSystemUser = true;
      createHome = true;
      group = "drone";
    };
    groups."drone" = {};
  };

  reverse-proxy = {
    enable = true;
    hosts = {
      "ci" = {
        domains = [ "ci.home.open-desk.net" ];
        target = "http://localhost:3030";
      };
    };
  };
}
