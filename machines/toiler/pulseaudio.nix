{ config, lib, pkgs, ... }:

{
  nixpkgs.config.pulseaudio = true;

  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
    tcp = {
      enable = true;
      anonymousClients.allowedIpRanges = [ "172.23.200.128/25" ];
    };
    zeroconf = {
      publish.enable = true;
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      pulseaudio = between ["established"] ["drop"] ''
        ip saddr 172.23.200.0/24
        tcp dport 4713
        accept
      '';
    };
  };
}
