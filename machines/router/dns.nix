{ config, lib, pkgs, ... }:

{
  services.kresd = {
    enable = true;

    listenPlain = [
      "53"
    ];

    listenTLS = [
      "853"
    ];

    extraConfig = ''
      modules = { 'hints > iterate' }

      hints['mqtt.iot.home.open-desk.net'] = '192.168.0.1'
      hints['hass.home.open-desk.net'] = '172.23.200.129'
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
