{ config, pkgs, ... }:

{
  services.gitea = {
    enable = true;

    lfs.enable = true;

    settings = {
      server = {
        ROOT_URL = "https://git.home.open-desk.net/";
        HTTP_PORT = 4000;
        HTTP_ADDR = "::1";
        DOMAIN = "git.home.open-desk.net";
      };

      service = {
        DISABLE_REGISTRATION = true;
      };

      session = {
        COOKIE_SECURE = true;
      };
    };

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

  web.reverse-proxy = {
    "git" = {
      domains = [ "git.home.open-desk.net" ];
      target = "http://[${config.services.gitea.settings.server.HTTP_ADDR}]:${toString config.services.gitea.settings.server.HTTP_PORT}";
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
            ${ gitea-dump } \
            > gitea-dump.tar
        ''
      )
    ];
  };
}
