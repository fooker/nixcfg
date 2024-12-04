{ config, ... }:

{
  users = {
    users."share" = {
      hashedPasswordFile = config.sops.secrets."users/share/password".path;

      isSystemUser = true;
      group = "share";
    };
    groups."share" = { };
  };

  services.samba = {
    enable = true;
    settings = {
      "global" = {
        "security" = "user";

        "guest account" = "nobody";
        "map to guest" = "bad user";

        "server multi channel support" = true;

        "deadtime" = 30;

        "use sendfile" = true;

        "aio read size" = 1;
        "aio write size" = 1;

        "load printers" = false;
        "printcap name" = "/dev/null";

        "valid users" = "@share, nobody";
      };

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

      "docs" = {
        "browseable" = "no";
        "guest ok" = "no";
        "path" = "/mnt/docs";
        "read only" = false;
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "share";
        "force group" = "share";
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

  sops.secrets."users/share/password" = {
    neededForUsers = true;
  };
}
