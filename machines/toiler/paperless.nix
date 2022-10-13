{ lib, pkgs, config, nodes, ... }:

with lib;

{
  fileSystems."/mnt/docs" = {
    device = "//nas.dev.home.open-desk.net/docs";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "username=share"
      "password=${nodes."nas".config.users.users."share".password}"
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
    };
  };

  web.reverse-proxy = {
    "paperless" = {
      domains = [ "docs.home.open-desk.net" ];
      target = "http://${config.services.paperless.address}:${toString config.services.paperless.port}/";
      extraConfig = ''
        client_max_body_size 128M;
      '';
    };
  };

  backup.paths = [
    config.services.paperless.dataDir
  ];
}
