{ lib, pkgs, inputs, ... }:

with lib;

let
  apps = {
    "box" = {
      domains = [ "box.open-desk.net" ];
      root = "/srv/http/box";
    };

    "blog" = {
      domains = [ "open-desk.org" "www.open-desk.org" ];
      root = pkgs.callPackage inputs.blog { };
    };

    "sofastroemer" = {
      domains = [ "sofa.open-desk.net" ];
      root = pkgs.callPackage "${inputs.sofastroemer}/frontend" { };
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
}
