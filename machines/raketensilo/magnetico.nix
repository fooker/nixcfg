{ pkgs, inputs, config, device, ... }:

let
  secrets = import ./secrets.nix;

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

      privateKeyFile = config.deployment.keys."magnetico-vpn-key".path;

      inherit peers;
    };

    data.enable = true;

    crawler.enable = true;
  };

  dns.zones = {
    net.open-desk.magnetico.data = { AAAA = device.interfaces.ext.address.ipv6.address; };
  };

  deployment.keys."magnetico-vpn-key" = {
    text = secrets.magnetico.vpn.privateKey;
    destDir = "/etc/secrets";
    user = "root";
    group = "systemd-network";
    permissions = "0640";
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
}
