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
        sha256 = "sha256-cRtpRs1s31l8xG84YkZIuR3C3pg2kQFNlrY2f5NTSBo=";
        url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
        version = "6.4.0";
      };

      contacts = pkgs.fetchNextcloudApp rec {
        name = "contacts";
        sha256 = "sha256-Oo7EFKlXxAAFFPQZzrpOx+6dpBb78r/yPxpDs6Cgw04=";
        url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
        version = "4.2.0";
      };

      calendar = pkgs.fetchNextcloudApp rec {
        name = "calendar";
        sha256 = "sha256-+LRGl9h40AQdWN9SW+NqGwTafAGwV07Af8nVs3pUCm0=";
        url = "https://github.com/nextcloud-releases/${name}/releases/download/v${version}/${name}-v${version}.tar.gz";
        version = "3.5.0";
      };

      tasks = pkgs.fetchNextcloudApp rec {
        name = "tasks";
        sha256 = "sha256-kXXUzzODi/qRi2NqtJyiS1GmLTx0kFAwtH1p0rCdnRM=";
        url = "https://github.com/nextcloud/${name}/releases/download/v${version}/${name}.tar.gz";
        version = "0.14.4";
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
