{ config, pkgs, ... }:

{
  services.woodpecker-server = {
    enable = true;

    environment = {
      "WOODPECKER_HOST" = "https://ci.home.open-desk.net";
      "WOODPECKER_SERVER_ADDR" = "localhost:3030";

      "WOODPECKER_OPEN" = "false";
      "WOODPECKER_ADMIN" = "fooker";

      "WOODPECKER_DATABASE_DRIVER" = "postgres";
      "WOODPECKER_DATABASE_DATASOURCE" = "postgres:///woodpecker?host=/run/postgresql";
      "WOODPECKER_DATABASE_SECRET_FILE" = config.sops.secrets."woodpecker/database".path;

      "WOODPECKER_GITEA" = "true";
      "WOODPECKER_GITEA_SERVER" = "https://git.home.open-desk.net";
      "WOODPECKER_GITEA_CLIENT_ID_FILE" = config.sops.secrets."woodpecker/forgejo/id".path;
      "WOODPECKER_GITEA_CLIENT_SECRET_FILE" = config.sops.secrets."woodpecker/forgejo/secret".path;

      "WOODPECKER_BACKEND" = "local";

      "WOODPECKER_RPC_SECRET_FILE" = config.sops.secrets."woodpecker/rpc".path;
    };
  };

  systemd.services.woodpecker-server = {
    serviceConfig = {
      User = "woodpecker";
    };
  };

  services.postgresql = {
    ensureDatabases = [ "woodpecker" ];
    ensureUsers = [{
      name = "woodpecker";
      ensureDBOwnership = true;
    }];
  };

  web.reverse-proxy = {
    "ci" = {
      domains = [ "ci.home.open-desk.net" ];
      target = "http://localhost:3030";
    };
  };

  sops.secrets."woodpecker/database" = { };
  sops.secrets."woodpecker/forgejo/id" = { };
  sops.secrets."woodpecker/forgejo/secret" = { };
  sops.secrets."woodpecker/rpc" = { };
}
