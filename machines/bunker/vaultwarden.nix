{ pkgs, config, ... }:

{
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vault.open-desk.net";

      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      SMTP_HOST = "smtp.open-desk.net";
      SMTP_FROM = "vault@open-desk.net";
      SMTP_PORT = 587;
      SMTP_SECURITY = "starttls";
    };

    environmentFile = config.sops.secrets."vaultwarden/env".path;
  };

  web.reverse-proxy = {
    "vault" = {
      domains = [ "vault.open-desk.net" ];
      target = with config.services.vaultwarden.config;
        "http://${ROCKET_ADDRESS}:${toString ROCKET_PORT}/";
    };
  };

  backup.jobs."docs" = {
    targets = [
      "default"
      {
        name = "borgbase";
        options.user = "t2t8gmt1";
      }
    ];
    commands = ''
      ${pkgs.sqlite}/bin/sqlite3 /var/lib/bitwarden_rs/db.sqlite3 .backup db.sqlite3
      cp /var/lib/bitwarden_rs/rsa_key.{der,pem,pub.der} .
      cp -r /var/lib/bitwarden_rs/attachments .
      cp -r /var/lib/bitwarden_rs/icon_cache .
    '';
  };

  sops.secrets."vaultwarden/env" = {
    format = "dotenv";
    sopsFile = ./secrets/vaultwarden.env;
  };
}
