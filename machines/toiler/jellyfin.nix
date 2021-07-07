{ pkgs, ... }:

let
  secrets = import ./secrets.nix;
in
{
  nixpkgs.overlays = [
    (self: super: {
      jellyfin = pkgs.unstable.jellyfin;
    })
  ];

  services.jellyfin = {
    enable = true;
  };

  fileSystems."/mnt/media" = {
    device = "nas.dev.home.open-desk.net:/media";
    fsType = "nfs4";
    options = [ "x-systemd.automount" "noauto" ];
  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 65536;
  };

  reverse-proxy.hosts = {
    "jellyfin" = {
      domains = [ "jellyfin.home.open-desk.net" ];
      target = "http://127.0.0.1:8096";
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      jellyfin-ssdp = between [ "established" ] [ "drop" ] ''
        ip saddr 172.23.200.0/24
        udp dport 1900
        accept
      '';
      jellyfin-disocovery = between [ "established" ] [ "drop" ] ''
        ip saddr 172.23.200.0/24
        udp dport 7359
        accept
      '';
    };
  };

  backup.paths = [
    "/var/lib/jellyfin"
  ];
}
