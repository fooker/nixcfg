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
    passwordFile = config.deployment.secrets."ddclient-password".destination;

    domains = [ "${domain}" ];

    use = "if, if=ppp0";
  };

  deployment.secrets = {
    "ddclient-password" = rec {
      source = "${path}/secrets/ddclient";
      destination = "/etc/secrets/ddclient";
    };
  };
}
