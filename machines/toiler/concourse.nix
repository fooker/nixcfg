{ pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {

  virtualisation.docker = {
    enable = true;
  };

  systemd.services.concourse = let
    dockerComposeFile = pkgs.writeText "docker-compose.yml" ''
      version: "2"
      services:
        concourse:
          image: concourse/concourse:6.4
          command: quickstart
          privileged: true
          restart: always
          environment:
            CONCOURSE_POSTGRES_HOST: db
            CONCOURSE_POSTGRES_USER: concourse
            CONCOURSE_POSTGRES_PASSWORD: concourse
            CONCOURSE_POSTGRES_DATABASE: concourse
            CONCOURSE_EXTERNAL_URL: "https://cd.open-desk.net"
            CONCOURSE_LOG_LEVEL: error
            CONCOURSE_GARDEN_LOG_LEVEL: error
          networks:
            - concourse
          ports:
            - "127.0.0.1:8080:8080"
          depends_on:
            - db
        db:
          image: postgres:12.3
          restart: always
          environment:
            POSTGRES_DB: concourse
            POSTGRES_PASSWORD: concourse
            POSTGRES_USER: concourse
            PGDATA: /database
          networks:
            - concourse
          volumes:
            - concourse_postgres:/database
      networks:
        concourse:
          external: false
      volumes:
        concourse_postgres:
    '';
  in {
    enable   = true;
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    environment = { COMPOSE_PROJECT_NAME = "concourse"; };
    serviceConfig = {
      ExecStart = "${pkgs.docker_compose}/bin/docker-compose -f '${dockerComposeFile}' up";
      ExecStop  = "${pkgs.docker_compose}/bin/docker-compose -f '${dockerComposeFile}' stop";
      Restart   = "always";
    };
  };

  networking.firewall.interfaces = {
    "priv" = {
      allowedTCPPorts = [ 8096 ];
    };
  };

  backup.paths = [
    "/var/lib/jellyfin"
  ];
}
