{ config, lib, pkgs, ... }:

{
  services.unbound = {
    enable = true;

    # interfaces = [ "0.0.0.0" ];

    # extraConfig = ''
    #   interface-automatic: yes
    # '';
  };

  networking.firewall.interfaces = lib.genAttrs [ "mngt" "priv" "guest" ] (iface: {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  });
}
