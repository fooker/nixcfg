{ config, lib, pkgs, ... }:

with lib;
let
  secrets = import ./secrets.nix;
in {
  services.pppd = {
    enable = true;

    peers = {
      uplink = {
        enable = true;
        autostart = true;

        config = with secrets.ppp.uplink; ''
          plugin rp-pppoe.so dsl
          
          linkname uplink
          
          user "${username}"
          password "${password}"
          
          lcp-echo-interval 15
          lcp-echo-failure 3

          hide-password

          asyncmap 0

          maxfail 0
          holdoff 5

          noauth
          noproxyarp

          defaultroute
          persist

          +ipv6
        '';
      };
    };
  };

  networking.firewall.extraCommands = ''
    iptables -A FORWARD -o ppp+ -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
  '';

  # Enfore redial once a day
  systemd = {
    services = {
      "pppd-uplink-redial" = {
        requires = [ "pppd-uplink.service" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.systemd}/bin/systemctl kill -s HUP --kill-who=main pppd-uplink";
        };
      };
    };
    timers = {
      "pppd-uplink-redial" = {
        bindsTo = [ "pppd-uplink.service" ];
        partOf = [ "pppd-uplink.service" ];
        timerConfig = {
          OnCalendar = "*-*-* 05:00:00";
        };
      };
    };
  };
}
