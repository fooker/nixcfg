{ pkgs, lib, config, inputs, ... }:

with lib;

let
  kodi-with-plugins = pkgs.kodi-wayland.passthru.withPackages (kodiPkgs: with kodiPkgs; [
    # Content providers
    jellyfin
    netflix
    youtube

    # Metadata
    trakt

    # Gaming
    libretro
  ]);

in
{
  users.users."kodi" = {
    isNormalUser = true;
    extraGroups = [
      "video"
      "audio"
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
      ];
    };
  };
}
