{ config, pkgs, ... }:

{
  services.forgejo = {
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
      name = "forgejo";
      user = "forgejo";
      socket = "/var/run/postgresql";
    };
  };

  services.postgresql = {
    ensureDatabases = [ "forgejo" ];
    ensureUsers = [{
      name = "forgejo";
      ensureDBOwnership = true;
    }];
  };

  web.reverse-proxy = {
    "git" = {
      domains = [ "git.home.open-desk.net" ];
      target = "http://[${config.services.forgejo.settings.server.HTTP_ADDR}]:${toString config.services.forgejo.settings.server.HTTP_PORT}";
    };
  };

  backup = {
    paths = [
      config.services.forgejo.stateDir
    ];

    commands = [
      (
        let
          forgejo-dump = pkgs.writeScript "forgejo-dump" ''
            export USER=${ config.services.forgejo.user };
            export HOME=${ config.services.forgejo.stateDir };
            export FORGEJO_WORK_DIR=${ config.services.forgejo.stateDir };
      
            ${pkgs.forgejo}/bin/forgejo dump \
              --verbose \
              --database postgres \
              --type tar \
              --file -
          '';
        in
        ''
          ${pkgs.sudo}/bin/sudo \
            --user ${config.services.forgejo.user} \
            ${forgejo-dump} \
            > forgejo-dump.tar
        ''
      )
    ];
  };
}
