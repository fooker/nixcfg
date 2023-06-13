{ pkgs, lib, ... }:

with lib;

let
  opensearch-dashboard = pkgs.callPackage ../../packages/opensearch-dashboards { };
in
{
  environment.systemPackages = [ opensearch-dashboard ];

  web.reverse-proxy."osd" = {
    domains = [ "dashboard.magnetico.open-desk.net" ];
    target = "http://[::1]:5601";
  };
}
