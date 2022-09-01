{ config, lib, pkgs, inputs, ... }:

with lib;

let
  apps = {
    "box" = {
      domains = [ "box.open-desk.net" "frisch.cloud" "www.frisch.cloud" ];
      root = "/srv/http/box";
    };

    "blog" = {
      domains = [ "open-desk.org" "www.open-desk.org" ];
      root = pkgs.callPackage inputs.blog { };
    };

    "schoen-und-gut" =
      let
        php = pkgs.php.buildEnv { };
        site = pkgs.applyPatches {
          name = "schoen-und-gut-patched";
          src = inputs.schoen-und-gut;
          postPatch = ''
            sed -i '1s;^;#!${ php }/bin/php-cgi\n;' ./mail.php
          '';
        };
      in
      {
        domains = [ "schoen-und-gut.org" "www.schoen-und-gut.org" ];
        root = site;

        config = {
          locations."/mail.php" = {
            extraConfig = ''
              include ${pkgs.nginx}/conf/fastcgi.conf;
              include ${pkgs.nginx}/conf/fastcgi_params;

              fastcgi_pass unix:${config.services.fcgiwrap.socketAddress};
            '';
          };
        };
      };
  };

in
{
  hive.glusterfs.volumes = [ "http" ];

  web.apps = mapAttrs
    (_: app: {
      inherit (app) domains root;
      config = app.config or { };
    })
    apps;

  services.fcgiwrap = {
    enable = true;
    user = config.services.nginx.user;
  };
}
