{ config, lib, pkgs, path, ... }:

with lib;

let
  secrets = import ./secrets.nix;

  concourse = pkgs.stdenv.mkDerivation rec {
    name = "concourse-bin";

    src = pkgs.fetchurl {
      url = "https://github.com/concourse/concourse/releases/download/v6.5.1/concourse-6.5.1-linux-amd64.tgz";
      sha256 = "ec0ed4a68a7221edea8ded0f569655298419ef4de8f9193b59dcd5098a4a360c";
    };

    phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

    # dontStrip = true;
    # dontPatchELF = true;

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
    ];

    installPhase = ''
      install -m755 -D bin/concourse $out/bin/concourse
    '';
  };
in {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_12;
    ensureDatabases = [ "concourse" ];
    ensureUsers = [ {
        name = "concourse";
        ensurePermissions = {
          "DATABASE concourse" = "ALL PRIVILEGES";
        };
    } ];
  };

  users.users."concourse" = {
    home = "/var/lib/concourse";
    createHome = true;
    group = "concourse";
    isSystemUser = true;
  };

  users.groups."concourse" = {
  };

  systemd.services.concourse-web = {
    description = "Concourse CI Web Node";
    
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Restart = "always";
      RestartSec = "10s";
      StartLimitInterval = "1min";
      User = "concourse";
      Group = "concourse";
      ExecStart = "${concourse}/bin/concourse web";
    };

    environment = {
      "CONCOURSE_EXTERNAL_URL" = "https://concourse.home.open-desk.net";

      "CONCOURSE_ADD_LOCAL_USER" = "${concatMapStringsSep "," (e: with e; "${username}:${password}") secrets.concourse.users}";
      "CONCOURSE_MAIN_TEAM_LOCAL_USER" = "fooker";

      "CONCOURSE_SESSION_SIGNING_KEY" = "${config.users.users."concourse".home}/session_signing_key";
      "CONCOURSE_TSA_HOST_KEY" = "${config.users.users."concourse".home}/tsa_host_key";
      "CONCOURSE_TSA_AUTHORIZED_KEYS" = "${config.users.users."concourse".home}/worker_key.pub"; # Use the single worker key

      "CONCOURSE_POSTGRES_SOCKET" = "/var/run/postgresql";
      "CONCOURSE_POSTGRES_DATABASE" = "concourse";
      "CONCOURSE_POSTGRES_USER" = "concourse";
    };
  };

  systemd.services.concourse-worker = {
    description = "Concourse CI Worker Node";
    
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Restart = "always";
      RestartSec = "10s";
      StartLimitInterval = "1min";
      User = "root";
      Group = "root";
      ExecStart = "${concourse}/bin/concourse worker";
    };

    environment = {
      "CONCOURSE_WORK_DIR" = "/var/cache/concourse/worker";
      "CONCOURSE_TSA_HOST" = "127.0.0.1:2222";
      "CONCOURSE_TSA_PUBLIC_KEY" = "${config.users.users."concourse".home}/tsa_host_key.pub";
      "CONCOURSE_TSA_WORKER_PRIVATE_KEY" = "${config.users.users."concourse".home}/worker_key";
    };
  };

  reverse-proxy = {
    enable = true;
    hosts = {
      "concourse" = {
        domains = [ "concourse.home.open-desk.net" ];
        target = "http://[::1]:8080";
      };
    };
  };

  environment.systemPackages = [ concourse pkgs.fly ];

  backup.paths = [
    config.users.users."concourse".home
  ];

  deployment.secrets = {
    "concourse.session_signing_key" = {
      source = "${path}/secrets/concourse/session_signing_key";
      destination = "${config.users.users."concourse".home}/session_signing_key";
      owner.user = "concourse";
      owner.group = "concourse";
    };

    "concourse.tsa_host_key" = rec {
      source = "${path}/secrets/concourse/tsa_host_key";
      destination = "${config.users.users."concourse".home}/tsa_host_key";
      owner.user = "concourse";
      owner.group = "concourse";
      action = [ ''
        ${pkgs.openssh}/bin/ssh-keygen -y -f ${destination} > ${destination}.pub
      '' ];
    };

    "concourse.worker_key" = rec {
      source = "${path}/secrets/concourse/worker_key";
      destination = "${config.users.users."concourse".home}/worker_key";
      owner.user = "concourse";
      owner.group = "concourse";
      action = [ ''
        ${pkgs.openssh}/bin/ssh-keygen -y -f ${destination} > ${destination}.pub
      '' ];
    };
  };
}
