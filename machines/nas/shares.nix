{ config, lib, pkgs, ... }:

{
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt            *(rw,fsid=root,no_subtree_check,root_squash)
      /mnt/docs       *(rw,no_subtree_check,root_squash)
      /mnt/downloads  *(rw,no_subtree_check,root_squash)
      /mnt/media      *(rw,no_subtree_check,root_squash)
      /mnt/scanner    *(rw,no_subtree_check,root_squash)
      /mnt/machines   *(rw,no_subtree_check,root_squash)
    '';
  };

  services.samba = {
    enable = true;
    securityType = "user";
    shares = {
      "downloads" = {
        "browseable" = "yes";
        "guest ok" = "yes";
        "path" = "/mnt/downloads";
        "read only" = true;
      };
      "media" = {
        "browseable" = "yes";
        "guest ok" = "yes";
        "path" = "/mnt/media";
        "read only" = true;
      };
      "scanner" = {
        "browseable" = "yes";
        "guest ok" = "yes";
        "path" = "/mnt/scanner";
        "read only" = false;
      };
    };

    extraConfig = ''
      guest account = nobody
      map to guest = bad user

      server multi channel support = yes
      
      deadtime = 30
      
      use sendfile = yes
      
      aio read size = 1
      aio write size = 1

      load printers = no
      printcap name = /dev/null
    '';
  };

  services.rpcbind.enable = true;

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      nfs-tcp = between ["established"] ["drop"] ''
        ip saddr 172.23.200.0/24
        tcp dport 2049
        accept
      '';
      nfs-udp = between ["established"] ["drop"] ''
        ip saddr 172.23.200.0/24
        udp dport 2049
        accept
      '';

      smb-tcp = between ["established"] ["drop"] ''
        ip saddr 172.23.200.0/24
        tcp dport { 137, 138, 139, 445 }
        accept
      '';
      smb-udp = between ["established"] ["drop"] ''
        ip saddr 172.23.200.0/24
        udp dport { 137, 138, 139, 445 }
        accept
      '';
    };
  };
}
