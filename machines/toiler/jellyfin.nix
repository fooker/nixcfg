{
  nixpkgs.overlays = [
    (self: _: {
      jellyfin = self.unstable.jellyfin;
    })
  ];

  services.jellyfin = {
    enable = true;
  };

  systemd.services.jellyfin.unitConfig = {
    RequiresMountsFor = "/mnt/media";
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
      jellyfin = between [ "established" ] [ "drop" ] ''
        ip saddr 172.23.200.0/24
        udp dport { 1900, 7359 }
        accept
      '';
    };
  };

  backup.paths = [
    "/var/lib/jellyfin"
  ];
}
