{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in
{
  services.gitea = {
    enable = true;
    domain = "git.home.open-desk.net";

    rootUrl = "https://git.home.open-desk.net/";

    cookieSecure = true;
    disableRegistration = true;

    lfs.enable = true;

    httpPort = 4000;
    httpAddress = "::1";

    database = {
      type = "postgres";
      name = "gitea";
      user = "gitea";
      socket = "/var/run/postgresql";
    };
  };

  services.postgresql = {
    ensureDatabases = [ "gitea" ];
    ensureUsers = [{
      name = "gitea";
      ensurePermissions = {
        "DATABASE gitea" = "ALL PRIVILEGES";
      };
    }];
  };

  reverse-proxy.hosts = {
    "git" = {
      domains = [ "git.home.open-desk.net" ];
      target = "http://[${config.services.gitea.httpAddress}]:${toString config.services.gitea.httpPort}";
    };
  };

  backup = {
    paths = [
      config.services.gitea.stateDir
    ];

    commands = [
      (
        let
          gitea-dump = pkgs.writeScript "gitea-dump" ''
            export USER=${ config.services.gitea.user };
            export HOME=${ config.services.gitea.stateDir };
            export GITEA_WORK_DIR=${ config.services.gitea.stateDir };
      
            ${ pkgs.gitea }/bin/gitea dump \
              --verbose \
              --database postgres \
              --type tar \
              --file -
          '';
        in
        ''
          ${ pkgs.sudo }/bin/sudo \
            --user ${ config.services.gitea.user } \
            ${ gitea-dump }
            > gitea-dump.tar
        ''
      )
    ];
  };
}
