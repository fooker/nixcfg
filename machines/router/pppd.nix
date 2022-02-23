{ lib, pkgs, ... }:

with lib;

let
  secrets = import ./secrets.nix;
in
{
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

          +ipv6 ipv6cp-use-ipaddr
        '';
      };
    };
  };

  # Restart pppd if systemd-networkd restarts
  systemd.services."pppd-uplink" = {
    partOf = [ "systemd-networkd.service" ];
  };

  firewall.rules = dag: with dag; {
    inet.filter.forward = {
      ppp-clamp = before [ "drop" ] ''
        meta oifname "ppp*"
        tcp flags syn
        tcp option maxseg
        size set rt mtu
      '';
    };

    inet.nat.postrouting = {
      uplink = anywhere ''
        meta oifname "ppp*"
        ip version 4
        masquerade
      '';
    };
  };

  # Enfore redial once a day
  systemd.services."pppd-uplink-redial" = {
    requires = [ "pppd-uplink.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.systemd}/bin/systemctl kill -s HUP --kill-who=main pppd-uplink";
    };
  };
  systemd.timers."pppd-uplink-redial" = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "*-*-* 05:00:00";
    };
  };
}
