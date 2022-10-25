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
      twofactor_totp = pkgs.fetchNextcloudApp rec {
        name = "twofactor_totp";
        sha256 = "sha256-Wa2P6tpp75IxCsTG4B5DQ8+iTzR7yjKBi4ZDBcv+AOI=";
        url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
        version = "6.4.1";
      };

      contacts = pkgs.fetchNextcloudApp rec {
        name = "contacts";
        sha256 = "sha256-GTiyZsUHBXPgQ17DHAihmt2W/ZnAjDwfgwnujkRwk6A=";
        url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
        version = "4.2.2";
      };

      calendar = pkgs.fetchNextcloudApp rec {
        name = "calendar";
        sha256 = "sha256-Sw3yZ3unK/kx2gqEiPM4k3ojgy1RHs62Dpba13lAoY0=";
        url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
        version = "3.5.1";
      };

      mail = pkgs.fetchNextcloudApp rec {
        name = "mail";
        sha256 = "sha256-CLJ0SOpDM9flsqT9Nwn2XhntK8EHKqw03kKETdX6aJA=";
        url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
        version = "1.14.1";
      };

      tasks = pkgs.fetchNextcloudApp rec {
        name = "tasks";
        sha256 = "sha256-/foxaKyA6u8+LeUAnu4Co2msyNNd/YKD0fJUI73zxTI=";
        url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}.tar.gz";
        version = "0.14.5";
      };

      news = pkgs.fetchNextcloudApp rec {
        name = "news";
        sha256 = "sha256-lVF4H9v7bSw8137lfq4PsVg8e1TpcgvJVQU/UVQfSoY=";
        url = "https://github.com/nextcloud/${name}/releases/download/${version}/${name}.tar.gz";
        version = "19.0.0";
      };

      groupfolders = pkgs.fetchNextcloudApp rec {
        name = "groupfolders";
        sha256 = "sha256-RHkvpAWH4HbKbM4ZoUy1HCzydVdw2SYQJvzO02sZEVQ=";
        url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}.tar.gz";
        version = "12.0.2";
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
