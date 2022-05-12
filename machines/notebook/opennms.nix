{ pkgs, config, ... }:

{
  # Hack required to get running nodejs downloaded by maven (who even things this is a god idea?)
  system.activationScripts.ldso = pkgs.lib.stringAfter [ "usrbinenv" ] ''                       
    mkdir -m 0755 -p /lib64                                                                
    ln -sfn ${pkgs.glibc.out}/lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2.tmp   
    mv -f /lib64/ld-linux-x86-64.so.2.tmp /lib64/ld-linux-x86-64.so.2 # atomically replace 
  '';

  users = {
    users."opennms" = {
      isSystemUser = true;
      group = "opennms";
    };
    groups."opennms" = { };
  };

  services.openvpn.servers.opennms = {
    autoStart = false;
    config = "config ${config.deployment.keys."openvpn-opennms".path}";
  };

  deployment.keys = {
    "openvpn-opennms" = {
      keyFile = toString ./secrets/opennms.ovpn;
      destDir = "/etc/secrets";
      user = "root";
      group = "root";
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
