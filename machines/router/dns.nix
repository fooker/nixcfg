{ config, lib, pkgs, ... }:

with lib;

let
  secrets = import ./secrets.nix;

  interfaces = [
    "192.168.0.1"
    "192.168.254.1"
    "172.23.200.129"
    "203.0.113.1"
  ];
in {
  services.kresd = {
    enable = true;

    listenPlain = map (iface: "${iface}:53") interfaces;
    listenTLS = map (iface: "${iface}:853") interfaces;

    extraConfig = ''
      modules.load('workarounds < iterate')
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

  networking.firewall.interfaces = lib.genAttrs [ "mngt" "priv" "guest" "iot" ] (iface: {
    allowedTCPPorts = [ 53 853 ];
    allowedUDPPorts = [ 53 5353 ];
  });
}
