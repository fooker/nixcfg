{ lib, config, name, ... }:

with lib;

{
  config = mkIf (name == "zitadelle-north") {
    services.tandoor-recipes = {
      enable = true;

      extraConfig = {
        SECRET_KEY_FILE = config.sops.secrets."tandoor/secret_key".path;

        DB_ENGINE = "django.db.backends.sqlite3";
      };
    };

    web.reverse-proxy."mampf" = {
      domains = [
        "tandoor.open-desk.net"
        "mampf.frisch.cloud"
      ];

      target = "http://127.0.0.1:${toString config.services.tandoor-recipes.port}/";
    };

    sops.secrets."tandoor/secret_key" = {
      sopsFile = ./secrets.yaml;
    };

    sops.secrets."tandoor/database/password" = {
      sopsFile = ./secrets.yaml;
    };
  };
}

