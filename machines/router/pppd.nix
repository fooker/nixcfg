{ config, lib, pkgs, ... }:

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
}
