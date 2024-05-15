{ pkgs
, lib
, config
, inputs
, ...
}:

with lib;

{
  imports = [
    inputs.bitmagnet.nixosModules.default
  ];

  bitmagnet = {
    enable = true;

    vpn = {
      privateKeyFile = config.sops.secrets."bitmagnet/vpn/privateKey".path;
      peers = import inputs.bitmagnet-peers;
    };

    database = {
      host = "raketensilo";

      server.enable = true;
    };

    queue = {
      enable = true;
      tmdb = {
        enable = true;
        apiKeyFile = config.sops.secrets."bitmagnet/tmdb/apiKey".path;
      };
    };

    web.enable = true;
  };

  sops.secrets."bitmagnet/vpn/privateKey" = {
    owner = "systemd-network";
  };
  sops.secrets."bitmagnet/tmdb/apiKey" = { };

  web.reverse-proxy = {
    "bitmagnet" = {
      domains = [ "bitmagnet.open-desk.net" ];
      target = "http://127.0.0.1:3333";
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      bitmagnet-vpn = between [ "established" ] [ "drop" ] [
        ''
          iifname ext
          udp dport ${toString config.bitmagnet.vpn.self.endpoint.port}
          accept
        ''
        ''
          iifname ${config.bitmagnet.vpn.netdev}
          accept
        ''
      ];
    };
  };
}

