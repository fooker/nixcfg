{ config, lib, network, ... }:

with lib;

{
  services.icecast = {
    enable = true;
    hostname = "cast.open-desk.org";

    admin = {
      user = "admin";
      password = "admin";
    };

    extraConf = ''
       <logging>
         <loglevel>4</loglevel> <!-- 4 Debug, 3 Info, 2 Warn, 1 Error -->
       </logging>

       <authentication>
         <source-password>password</source-password>
       </authentication>

       <mount type="normal">
        <mount-name>/rapz.ogg</mount-name>
        <max-listeners>32</max-listeners>
        <hidden>false</hidden>
        <public>false</public>
      </mount>
    '';
  };

  web.apps."cast" = {
    domains = [ config.services.icecast.hostname ];
    config = {
      locations."= /rapz.ogg" = {
        proxyPass = "http://[::1]:${toString config.services.icecast.listen.port}/rapz.ogg";

        extraConfig = ''
          chunked_transfer_encoding on;

          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };
    };
  };

  firewall.rules =
    let
      nas = {
        ipv4 = toString network.devices."nas".interfaces."priv".address.ipv4.address;
        ipv6 = toString network.devices."nas".interfaces."priv".address.ipv6.address;
      };
    in
    dag: with dag; {
      inet.filter.input = {
        cast = between [ "established" ] [ "drop" ] [
          ''ip saddr "${nas.ipv4}" tcp dport ${toString config.services.icecast.listen.port} accept''
          ''ip6 saddr "${nas.ipv6}" tcp dport ${toString config.services.icecast.listen.port} accept''
        ];
      };
    };
}

