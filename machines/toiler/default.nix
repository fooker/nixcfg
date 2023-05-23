{
  imports = [
    ./hardware.nix
    ./network.nix
    ./jellyfin.nix
    ./snapcast.nix
    ./pulseaudio.nix
    ./mopidy.nix
    ./spotifyd.nix
    ./gitea.nix
    ./drone.nix
    ./scanner.nix
    ./paperless.nix
    ./hass.nix
  ];

  server.enable = true;

  dns.host = {
    realm = "home";
    interface = "priv";
  };

  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      avahi = between [ "established" ] [ "drop" ] ''
        ip saddr 172.23.200.0/24
        udp dport 5353
        accept
      '';
    };
  };

  fileSystems."/mnt/media" = {
    device = "//nas.dev.home.open-desk.net/media";
    fsType = "cifs";
    options = [ "x-systemd.automount" "noauto" "guest" ];
  };
}
