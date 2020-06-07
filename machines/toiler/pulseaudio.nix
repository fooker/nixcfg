{ config, lib, pkgs, ... }:

{
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

  networking.firewall.interfaces = {
    "priv" = {
      allowedTCPPorts = [ 4713 ];
    };
  };
}