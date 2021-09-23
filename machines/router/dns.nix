{ lib, pkgs, ... }:

with lib;

{
  /* Let systemd-resolved not listen on 127.0.0.53:53 to avoid conflicts with
    kresd listening on wildcard.
  */
  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  services.kresd = {
    enable = true;
    package = pkgs.knot-resolver.override { extraFeatures = true; };

    listenPlain = [ "0.0.0.0:53" "[::]:53" ];
    listenTLS = [ "0.0.0.0:853" "[::]:853" ];

    extraConfig = ''
      modules.load('workarounds < iterate')
      modules.load('stats')
      modules.load('predict')

      predict.config {
        window = 15,
        period = 6 * (60 / 15),
      }
    '';
  };

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
    };
    reflector = true;
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      dns = between [ "established" ] [ "drop" ] [
        ''meta iifname { mngt, priv, guest, iot } tcp dport { 53, 853 } accept''
        ''meta iifname { mngt, priv, guest, iot } udp dport { 53 } accept''
      ];

      dns-avahi = between [ "established" ] [ "drop" ] ''
        meta iifname { mngt, priv, guest, iot }
        udp dport 5353
        accept
      '';
    };
  };
}
