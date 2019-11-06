{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
  ];

  networking.hostName = "router";
  networking.interfaces."int.l".useDHCP = true;
  networking.interfaces."int.r".useDHCP = true;

  networking.ppp = {
    enable = true;

    peers = {
      uplink = {
        username = secrets.ppp.uplink.username;
        password = secrets.ppp.uplink.password;
        interface = "ext.dsl";
        pppoe = true;
        extraOptions = ''
          lock

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
