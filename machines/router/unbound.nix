{ config, lib, pkgs, ... }:

{
  services.unbound = {
    enable = true;

    interfaces = [
      "127.0.0.1"
      "192.168.254.1"   # mngt
      "172.23.200.129"  # priv
      "203.0.113.1"     # guest
      # "192.168.0.1"     # iot
    ];

    allowedAccess = [
      "127.0.0.0/24"
      "192.168.254.0/24"   # mngt
      "172.23.200.128/25"  # priv
      "203.0.113.0/24"     # guest
      # "192.168.0.0/24"     # iot
    ];

    # extraConfig = ''
    #   interface-automatic: yes
    # '';
  };

  networking.firewall.interfaces = lib.genAttrs [ "mngt" "priv" "guest" "iot" ] (iface: {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  });
}
