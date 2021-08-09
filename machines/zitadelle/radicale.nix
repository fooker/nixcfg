{ pkgs, lib, ... }:

with lib;

let
  secrets = import ./secrets.nix;

  credentials = pkgs.writeText "radicale-credentials"
    (concatStringsSep "\n" (mapAttrsToList
      (user: hash: "${user}:${hash}")
      secrets.radicale.credentials));
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
        filesystem_folder = "/srv/calendar";
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

  reverse-proxy.hosts = {
    "calendar" = {
      domains = [ "calendar.open-desk.net" ];
      target = "http://127.0.0.1:5232/";
    };
  };

  backup.paths = [
    "/srv/calendar"
  ];
}
