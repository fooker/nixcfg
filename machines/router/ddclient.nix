{ config, lib, pkgs, ... }:

with lib;
let
  secrets = import ./secrets.nix;
in
{
  services.ddclient = with secrets.ddclient.basis;  {
    enable = true;

    interval = "5min";

    protocol = "noip";

    server = "ddserver.org";

    username = "${username}";
    password = "${password}";

    domains = [ "${domain}" ];

    use = "if, if=ppp0";
  };
}
