{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./unbound.nix
  ];

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

  environment.systemPackages = with pkgs; [
    wget vim
  ];

  services.openssh.enable = true;

  system.stateVersion = "19.09";
}
