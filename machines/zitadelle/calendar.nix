{ pkgs, lib, ... }:

with lib;

let
  secrets = import ./secrets.nix;

  credentials = pkgs.writeText "radicale-credentials"
    (concatStringsSep "\n" (mapAttrsToList
      (user: hash: "${user}:${hash}")
      secrets.radicale.credentials));

  storage = "/srv/calendar";

in
{
  services.radicale = {
    enable = true;

    settings = {
      server = { };

      auth = {
        type = "htpasswd";
        htpasswd_filename = toString credentials;
        htpasswd_encryption = "bcrypt";
      };

      storage = {
        filesystem_folder = storage;
      };
    };

    rights = {
      root = {
        user = ".+";
        collection = "";
        permissions = "R";
      };
      principal = {
        user = ".+";
        collection = "{user}";
        permissions = "RW";
      };
      calendars = {
        user = ".+";
        collection = "{user}/[^/]+";
        permissions = "rw";
      };
    };
  };

  systemd.services."radicale" = {
    unitConfig = {
      RequiresMountsFor = [ storage ];
    };
  };

  web.reverse-proxy = {
    "calendar" = {
      domains = [ "calendar.open-desk.net" ];
      target = "http://127.0.0.1:5232/";
    };
  };

  backup.paths = [
    storage
  ];
}
