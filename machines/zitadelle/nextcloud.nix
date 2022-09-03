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
      twofactor_totp = pkgs.fetchNextcloudApp {
        name = "twofactor_totp";
        sha256 = "sha256-cRtpRs1s31l8xG84YkZIuR3C3pg2kQFNlrY2f5NTSBo=";
        url = "https://github.com/nextcloud-releases/twofactor_totp/releases/download/v6.4.0/twofactor_totp-v6.4.0.tar.gz";
        version = "0.6.9";
      };
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
