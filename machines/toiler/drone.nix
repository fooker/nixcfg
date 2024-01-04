{ config, pkgs, ... }:

let
  secrets = import ./secrets.nix;

  drone-runner-docker = pkgs.callPackage ../../packages/drone-runner-docker.nix { };
  drone-runner-exec = pkgs.callPackage ../../packages/drone-runner-exec.nix { };
in
{
  systemd.services.drone-server = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment = [
        "DRONE_DATABASE_DATASOURCE=postgres:///drone?host=/run/postgresql"
        "DRONE_DATABASE_DRIVER=postgres"
        "DRONE_GITEA_SERVER=https://git.home.open-desk.net"
        "DRONE_SERVER_HOST=ci.home.open-desk.net"
        "DRONE_SERVER_PORT=:3030"
        "DRONE_SERVER_PROTO=https"
      ];
      EnvironmentFile = [
        config.sops.secrets."drone/database".path
        config.sops.secrets."drone/gitea".path
        config.sops.secrets."drone/rpc".path
      ];
      ExecStart = "${pkgs.drone}/bin/drone-server";
      User = "drone";
      Group = "drone";
    };
  };

  virtualisation.docker = {
    enable = true;
  };

  systemd.services.drone-runner-docker = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment = [
        "DRONE_RPC_HOST=ci.home.open-desk.net"
        "DRONE_RPC_PROTO=https"
        "DRONE_RUNNER_CAPACITY=10"
        "DRONE_RUNNER_NAME=${config.networking.hostName}-docker"
      ];
      EnvironmentFile = [
        config.sops.secrets."drone/rpc".path
      ];
      ExecStart = "${drone-runner-docker}/bin/drone-runner-docker";
      User = "drone-runner";
      Group = "drone-runner";
      SupplementaryGroups = [ "docker" ];
    };
  };

  systemd.services.drone-runner-exec = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment = [
        "DRONE_RPC_HOST=ci.home.open-desk.net"
        "DRONE_RPC_PROTO=https"
        "DRONE_RUNNER_CAPACITY=10"
        "DRONE_RUNNER_NAME=${config.networking.hostName}-exec"
        "NIX_REMOTE=daemon"
        "ENV=/etc/profile"

      ];
      EnvironmentFile = [
        config.sops.secrets."drone/rpc".path
      ];
      ExecStart = "${drone-runner-exec}/bin/drone-runner-exec";
      User = "drone-runner";
      Group = "drone-runner";
      BindPaths = [
        "/nix/var/nix/daemon-socket/socket"
      ];
      BindReadOnlyPaths = [
        "/usr/bin/env"
        "/bin/sh"
        "/etc/passwd"
        "/etc/group"
        "/etc/resolv.conf"
        "${config.environment.etc."ssl/certs/ca-certificates.crt".source}:/etc/ssl/certs/ca-certificates.crt"
        "${config.environment.etc."ssh/ssh_known_hosts".source}:/etc/ssh/ssh_known_hosts"
        "/etc/machine-id"
        "/nix/store"
        "/nix/var/nix/db"
        "/nix/var/nix/profiles/system/etc/nix:/etc/nix"
      ];
    };

    path = with pkgs; [
      git
      gnutar
      bash
      nixUnstable
      gzip
    ];

    confinement = {
      enable = true;
      packages = with pkgs; [
        git
        gnutar
        bash
        nixUnstable
        gzip
      ];
    };
  };

  environment.systemPackages = [ pkgs.drone-cli ];

  services.postgresql = {
    ensureDatabases = [ "drone" ];
    ensureUsers = [{
      name = "drone";
      ensureDBOwnership = true;
    }];
  };

  users = {
    users."drone" = {
      isSystemUser = true;
      createHome = true;
      group = "drone";
    };
    groups."drone" = { };

    users."drone-runner" = {
      isSystemUser = true;
      group = "drone-runner";
    };
    groups."drone-runner" = { };
  };

  web.reverse-proxy = {
    "ci" = {
      domains = [ "ci.home.open-desk.net" ];
      target = "http://localhost:3030";
    };
  };

  sops.secrets."drone/database" = { };
  sops.secrets."drone/gitea" = { };
  sops.secrets."drone/rpc" = { };
}
