{ pkgs, inputs, config, device, ... }:

let
  peers = import inputs.magnetico-peers;

in
{
  imports = [
    "${inputs.magnetico}/module"
  ];

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  magnetico = {
    enable = true;

    vpn = {
      network = "192.168.200.0/24";

      privateKeyFile = config.sops.secrets."magnetico/vpn/privateKey".path;

      inherit peers;
    };

    data.enable = true;

    crawler.enable = true;
  };

  dns.zones = {
    net.open-desk.magnetico.data = { AAAA = device.interfaces.ext.address.ipv6.address; };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      magnetico-vpn = between [ "established" ] [ "drop" ] [
        ''
          iifname ext
          udp dport ${toString config.magnetico.vpn.self.endpoint.port}
          accept
        ''
        ''
          iifname ${config.magnetico.vpn.netdev}
          accept
        ''
      ];
    };
  };

  sops.secrets."magnetico/vpn/privateKey" = { };
}
