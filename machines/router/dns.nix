{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  services.kresd = {
    enable = true;

    interfaces = [ "::" ];
    listenTLS = [ "853" ];

    extraConfig = ''
      modules.load('workarounds < iterate')
    '';
  };

  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  networking.firewall.interfaces = lib.genAttrs [ "mngt" "priv" "guest" "iot" ] (iface: {
    allowedTCPPorts = [ 53 853 ];
    allowedUDPPorts = [ 53 ];
  });
}
