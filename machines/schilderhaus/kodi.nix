{ pkgs, lib, ... }:

with lib;

let
  kodi-with-plugins = pkgs.kodi-wayland.passthru.withPackages (kodiPkgs: with kodiPkgs; [
    jellyfin
    netflix
    youtube
  ]);

in
{
  users.users."kodi" = {
    isNormalUser = true;
    extraGroups = [
      "video"
      "tty"
    ];
  };

  services.cage = {
    enable = true;
    user = "kodi";
    program = "${kodi-with-plugins}/bin/kodi-standalone";
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      kodi = between [ "established" ] [ "drop" ] [
        ''
          iifname int
          tcp dport 8080
          accept
        ''
        ''
          iifname int
          udp dport 8080
          accept
        ''
      ];
    };
  };
}
