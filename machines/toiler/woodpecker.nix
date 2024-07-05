{ config, pkgs, ... }:

{
  services.woodpecker-server = {
    enable = true;

    package = pkgs.unstable.woodpecker-server;

    environment = {
      "WOODPECKER_HOST" = "https://ci.home.open-desk.net";
      "WOODPECKER_SERVER_ADDR" = "localhost:3030";

      "WOODPECKER_OPEN" = "false";
      "WOODPECKER_ADMIN" = "fooker";

      "WOODPECKER_DATABASE_DRIVER" = "postgres";
      "WOODPECKER_DATABASE_DATASOURCE" = "postgres:///woodpecker?host=/run/postgresql";
      "WOODPECKER_DATABASE_SECRET_FILE" = config.sops.secrets."woodpecker/database".path;

      "WOODPECKER_FORGEJO" = "true";
      "WOODPECKER_FORGEJO_URL" = "https://git.home.open-desk.net";
      "WOODPECKER_FORGEJO_CLIENT_FILE" = config.sops.secrets."woodpecker/forgejo/client".path;
      "WOODPECKER_FORGEJO_SECRET_FILE" = config.sops.secrets."woodpecker/forgejo/secret".path;

      "WOODPECKER_BACKEND" = "local";

      "WOODPECKER_RPC_SECRET_FILE" = config.sops.secrets."woodpecker/rpc/secret".path;
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
  sops.secrets."woodpecker/forgejo/client" = { };
  sops.secrets."woodpecker/forgejo/secret" = { };
  sops.secrets."woodpecker/rpc/secret" = { };
}
