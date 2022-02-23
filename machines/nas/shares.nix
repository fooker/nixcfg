let
  secrets = import ./secrets.nix;
in
{
  users = {
    users."share" = {
      inherit (secrets.users."share") password;

      isSystemUser = true;
      group = "share";
    };
    groups."share" = { };
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
      "vault" = {
        "browseable" = "no";
        "guest ok" = "no";
        "path" = "/mnt";
        "read only" = false;
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "share";
        "force group" = "share";
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

      valid users = @share, nobody
    '';
  };

  services.rpcbind.enable = true;

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      smb = between [ "established" ] [ "drop" ] [
        ''ip saddr { 172.23.200.128/25, 172.23.200.127/32 } tcp dport { 139, 445 } accept''
        ''ip saddr { 172.23.200.128/25, 172.23.200.127/32 } udp dport { 137, 138 } accept''
        ''ip6 saddr { fd79:300d:6056:100::/64, fd79:300d:6056:ffff::0/128 } tcp dport { 139, 445 } accept''
        ''ip6 saddr { fd79:300d:6056:100::/64, fd79:300d:6056:ffff::0/128 } udp dport { 137, 138 } accept''
      ];
    };
  };
}
