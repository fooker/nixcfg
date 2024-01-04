{ config, lib, pkgs, ... }:

with lib;

let
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
    package = pkgs.nextcloud26; ## Dont forget to bump nexcloudPackages below

    datadir = "/srv/nextcloud";

    hostName = "nextcloud";
    https = true;

    caching = {
      redis = true;
    };

    config = {
      extraTrustedDomains = domains;
      adminpassFile = config.sops.secrets."nextcloud/adminPassword".path;

      dbhost = "localhost:/run/mysqld/mysqld.sock";
      dbuser = "nextcloud";
      dbtype = "mysql";
      dbname = "nextcloud";
    };

    extraApps = {
      inherit (pkgs.nextcloud26Packages.apps)
        contacts
        calendar
        mail
        tasks
        news
        groupfolders;
    };
    extraAppsEnable = true;
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

  sops.secrets."nextcloud/adminPassword" = {
    sopsFile = ./secrets.yaml;
    owner = "nextcloud";
  };
}
