{ config, lib, pkgs, ... }:

with lib;

let
  secrets = import ./secrets.nix;

  domains = [
    "frisch.cloud"
    "www.frisch.cloud"
    "cloud.open-desk.net"
  ];

in
{
  hive.glusterfs.volumes = [ "nextcloud" ];

  users.users."nextcloud".uid = 800;
  users.groups."nextcloud".gid = 800;

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud24;

    datadir = "/srv/nextcloud";

    hostName = "nextcloud";
    https = true;

    caching = {
      redis = true;
    };

    config = {
      extraTrustedDomains = domains;
      adminpassFile = config.deployment.keys."nextcloud.adminpass".path;

      dbhost = "localhost:/run/mysqld/mysqld.sock";
      dbuser = "nextcloud";
      dbtype = "mysql";
      dbname = "nextcloud";
    };

    extraApps = {
      twofactor_totp =
        let
          name = "twofactor_totp";
          version = "6.4.1";
        in
        pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-zAPNugbvngXcpgWJLD78YAg4G1QtGaphx1bhhg7mLKE=";
          url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
        };

      contacts =
        let
          name = "contacts";
          version = "4.2.2";
        in
        pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-eTc51pkg3OdHJB7X4/hD39Ce+9vKzw1nlJ7BhPOzdy0=";
          url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
        };

      calendar =
        let
          name = "calendar";
          version = "3.5.1";
        in
        pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-QDnn3TYszn3OkDPdH382bxfq7pc06mfr8wP0U7ifxOA=";
          url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
        };

      mail =
        let
          name = "mail";
          version = "1.14.1";
        in
        pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-sQUsYC3cco6fj9pF2l1NrCEhA3KJoOvJRhXvBlVpNqo=";
          url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
        };

      tasks =
        let
          name = "tasks";
          version = "0.14.5";
        in
        pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-pbcw6bHv1Za+F351hDMGkMqeaAw4On8E146dak0boUo=";
          url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}.tar.gz";
        };

      news =
        let
          name = "news";
          version = "19.0.0";
        in
        pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-Fx8QKR/UKAhcWtqBcinecE0tlPGFXG9kVBPnTdXX16k=";
          url = "https://github.com/nextcloud/${name}/releases/download/${version}/${name}.tar.gz";
        };

      groupfolders =
        let
          name = "groupfolders";
          version = "12.0.2";
        in
        pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-QDnn3TYszn3OkDPdH382bxfq7pc06mfr8wP0U7ifxOA=";
          url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}.tar.gz";
        };
    };
  };

  systemd.services."nextcloud-setup" = {
    unitConfig = {
      RequiresMountsFor = config.services.nextcloud.datadir;
    };
  };

  web.apps."nextcloud" = {
    inherit domains;
  };

  backup.paths = [
    "/srv/nextcloud"
  ];

  deployment.keys."nextcloud.adminpass" = {
    text = secrets.nextcloud.adminPassword;
    destDir = "/etc/secrets";
    user = "nextcloud";
    group = "nextcloud";
  };
}
