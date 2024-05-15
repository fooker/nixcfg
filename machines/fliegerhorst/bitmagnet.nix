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
    };

    crawler.enable = true;
  };

  sops.secrets."bitmagnet/vpn/privateKey" = {
    owner = "systemd-network";
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

