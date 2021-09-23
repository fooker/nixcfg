{ pkgs, ... }:

{
  # Hack required to get running nodejs downloaded by maven (who even things this is a god idea?)
  system.activationScripts.ldso = pkgs.lib.stringAfter [ "usrbinenv" ] ''                       
    mkdir -m 0755 -p /lib64                                                                
    ln -sfn ${pkgs.glibc.out}/lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2.tmp   
    mv -f /lib64/ld-linux-x86-64.so.2.tmp /lib64/ld-linux-x86-64.so.2 # atomically replace 
  '';

  users.users."opennms" = {
    isSystemUser = true;
  };

  services.openvpn.servers.opennms = {
    autoStart = false;
    config = "config /etc/openvpn/opennms.ovpn";
  };

  deployment.secrets = {
    "openvpn-opennms" = {
      source = toString ./secrets/opennms.ovpn;
      destination = "/etc/openvpn/opennms.ovpn";
      owner.user = "root";
      owner.group = "root";
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      opennms = between [ "established" ] [ "drop" ] [
        ''tcp dport { 8980 } accept''
        ''udp dport { 9999 } accept''
      ];
    };
  };
}
