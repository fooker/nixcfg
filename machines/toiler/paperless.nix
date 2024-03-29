{ lib, pkgs, config, nodes, ... }:

with lib;

{
  fileSystems."/mnt/docs" = {
    device = "//nas.dev.home.open-desk.net/docs";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "credentials=${config.sops.secrets."mounts/vault/credentials".path}"
      "uid=${toString config.users.users.${config.services.paperless.user}.uid}"
    ];
  };

  services.paperless = {
    enable = true;
    package = pkgs.paperless-ngx;

    mediaDir = "/mnt/docs";

    extraConfig = {
      PAPERLESS_DBHOST = "/run/postgresql";
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_CLEAN = "clean-final";
      PAPERLESS_CONVERT_TMPDIR = "/var/lib/paperless/tmp";
      PAPERLESS_WORKER_TIMEOUT = "3600";
    };

    consumptionDirIsPublic = true;
  };

  systemd.services.paperless-scheduler.after = [ "mnt-docs.mount" ];
  systemd.services.paperless-consumer.after = [ "mnt-docs.mount" ];
  systemd.services.paperless-web.after = [ "mnt-docs.mount" ];

  web.reverse-proxy = {
    "paperless" = {
      domains = [ "docs.home.open-desk.net" ];
      target = "http://${config.services.paperless.address}:${toString config.services.paperless.port}/";
      extraConfig = ''
        client_max_body_size 512M;
      '';
    };
  };

  services.postgresql = {
    ensureDatabases = [ "paperless" ];
    ensureUsers = [{
      name = "paperless";
      ensureDBOwnership = true;
    }];
  };

  backup.paths = [
    config.services.paperless.dataDir
  ];

  sops.secrets."mounts/vault/credentials" = { };
}
