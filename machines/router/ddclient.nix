{ lib, path, config, ... }:

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
    passwordFile = config.deployment.keys."ddclient-password".path;

    domains = [ "${domain}" ];

    use = "if, if=ppp0";
  };

  deployment.keys = {
    "ddclient-password" = rec {
      keyFile = "${path}/secrets/ddclient";
      destDir = "/etc/secrets";
    };
  };
}
