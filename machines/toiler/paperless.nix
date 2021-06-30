{ lib, pkgs, config, ... }:

with lib;

let
  secrets = import ./secrets.nix;

  port = 28981;

  paperless = (pkgs.callPackage ../../packages/paperless-ng.nix {});
  configured = paperless.withConfig {
    PAPERLESS_STATICDIR = paperless.static;

    PAPERLESS_DATA_DIR = config.users.users."paperless".home;
    PAPERLESS_CONSUMPTION_DIR = "${config.users.users."paperless".home}/consume";
    PAPERLESS_MEDIA_ROOT = "/mnt/docs";

    PAPERLESS_SECRET_KEY = secrets.paperless.secret;

    PAPERLESS_OCR_LANGUAGE = "deu+eng";
    PAPERLESS_OCR_CLEAN = "clean-final";

    PAPERLESS_INLINE_DOC = "true";
    PAPERLESS_DISABLE_LOGIN = "true";
  };

in {
  systemd.tmpfiles.rules = [
    "d '${config.users.users."paperless".home}' - paperless paperless - -"
    "d '${config.users.users."paperless".home}/consume' 777 - - - -"
  ];

  fileSystems."/mnt/docs" = {
    device = "nas.dev.home.open-desk.net:/docs";
    fsType = "nfs4";
    options = ["x-systemd.automount" "noauto"];
  };

  users = {
    users."paperless" = {
      group = "paperless";
      home = "/var/lib/paperless";
      createHome = true;
      isSystemUser = true;
    };

    groups."paperless" = {
    };
  };

  services.redis.enable = true;

  systemd.services.paperless-consumer = {
    description = "Paperless-ng document consumer";

    serviceConfig = {
      User = "paperless";
      ExecStart = "${configured}/bin/paperless-ng document_consumer";
      Restart = "always";
    };

    bindsTo = [ "mnt-docs.mount" ];
    after = [ "mnt-docs.mount" "systemd-tmpfiles-setup.service" ];

    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.paperless-processor = {
    description = "Paperless-ng document processor";
    
    serviceConfig = {
      User = "paperless";
      ExecStart = "${configured}/bin/paperless-ng qcluster";
      Restart = "always";
    };

    # Bind to `paperless-consumer` so that the server never runs
    # during migrations
    bindsTo = [ "paperless-consumer.service" ];
    after = [ "paperless-consumer.service" ];
    
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.paperless-server = {
    description = "Paperless-ng document server";
    
    serviceConfig = {
      User = "paperless";
      ExecStart = "${configured}/bin/paperless-ng runserver --noreload localhost:${toString port}";
      Restart = "always";
    };

    # Bind to `paperless-consumer` so that the server never runs
    # during migrations
    bindsTo = [ "paperless-consumer.service" ];
    after = [ "paperless-consumer.service" ];
    
    wantedBy = [ "multi-user.target" ];
  };

  reverse-proxy.hosts = {
    "paperless" = {
      domains = [ "docs.home.open-desk.net" ];
      target = "http://localhost:${toString port}/";
    };
  };

  environment.systemPackages = [ configured ];

  backup.paths = [
    config.users.users."paperless".home
  ];
}