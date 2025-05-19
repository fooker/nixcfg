{ lib, path, config, ... }:

with lib;
{
  services.ddclient = {
    enable = true;

    interval = "5min";

    protocol = "noip";

    server = "ddserver.org";

    username = "fooker";
    passwordFile = config.sops.secrets."ddserver/password".path;

    domains = [ "basis.ddserver.org" ];

    usev4 = "ipv4, ipv4=ppp0";
  };

  sops.secrets."ddserver/password" = { };
}
