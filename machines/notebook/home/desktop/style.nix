{ pkgs, lib, config, inputs, ... }:

with lib;

let
  fetchFileFromZip = { url, hash, file }: pkgs.runCommandNoCCLocal "wallpaper"
    {
      src = pkgs.fetchzip {
        inherit url hash;
        stripRoot = false;
      };

      inherit file;
    } ''
    cp "$src/$file" "$out"
  '';

  wallpapers = {
    black = pkgs.fetchurl {
      url = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/1280px-A_black_image.jpg";
      hash = "sha256-m5G/qK4LQUo0Y+UapX1l5DGHwE+1MiEBufY5hVz9RUA=";
    };

    orange-dots = pkgs.fetchurl {
      url = "https://images.pexels.com/photos/949587/pexels-photo-949587.jpeg";
      hash = "sha256-Cgl0EuLzivw4ZxemW7HNdigeffBZ2VNGf2O7vBMKWr8=";
    };

    space-nebula = pkgs.fetchurl {
      url = "https://uhdwallpapers.org/download/carina-nebula_665898/3840x2160/";
      hash = "sha256-nXRTclm/wUYifuAQ8uarYHkdUFtRWIXMvaMfLdidrog=";
    };

    cartoon-nature-night = fetchFileFromZip {
      url = "https://files.vecteezy.com/system/protected/files/013/455/493/vecteezy_cartoon-nature-night-time-landscape-background_13455493_171.zip";
      hash = "sha256-A7eQHIBNtu7iu/bXrkHl7jA8I4LenIQUsAm2QRTNgaY=";
      file = "vecteezy_cartoon-nature-night-time-landscape-background_13455493.jpg";
    };

    blue-city = pkgs.fetchurl {
      url = "https://images.hdqwalls.com/wallpapers/architecture-buildings-city-5k-bl.jpg";
      hash = "sha256-8gn3e1e8yHLzOhgI6D2gBKsoE0AmuJ2aZdY7VvauTRs=";
    };

    graffiti = pkgs.fetchurl {
      url = "https://images.hdqwalls.com/wallpapers/abstract-vandalism-shapes-alive-ol.jpg";
      hash = "sha256-JDzC5aaAMCdcIOMSYDf5j8NW+1KPFgDEFySXf0Mqtt8=";
    };

    isometric = pkgs.fetchurl {
      url = "https://images.hdqwalls.com/wallpapers/isometric-abstract-5k-hj.jpg";
      hash = "sha256-pJI8Nm4hK51r9/5AiMUm9htTNfjqappWfjl6owWgDm4=";
    };

    pirate = pkgs.fetchurl {
      url = "https://images.hdqwalls.com/wallpapers/pirate-flag-scifi-city-5k-97.jpg";
      hash = "sha256-9w9ZMkFfEIIF6WJQn69tOkvUv1k978BGhVZbAS+EHGM=";
    };

    balloon = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/ne/wallhaven-nem99o.jpg";
      hash = "sha256-lhAzd7HycNQ/B5UMiEz8rmE5XhtWcEYdk3t743MZzM8=";
    };

    rainbow = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/0j/wallhaven-0j8775.jpg";
      hash = "sha256-+fHLfGic5iLZ9NcdiEf9/uWTg/v8SkmGjsZw2JqEMkM=";
    };

    tent = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/rr/wallhaven-rrgmvm.jpg";
      hash = "sha256-h017SOIBDrYj+EIFNcp02jHNhoBDdIZX6V2jtGKGrqw=";
    };

    neon = pkgs.fetchurl {
      url = "https://images.unsplash.com/photo-1567400358510-f027b3196d5b";
      hash = "sha256-hmubQfagwBhVxcetmObWd7lYyqP/qPOIaybP3eCEk5I=";
    };
  };

in
{
  imports = [
    inputs.stylix.homeManagerModules.stylix
  ];

  stylix = {
    enable = true;

    image = config.lib.stylix.pixel "base00";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/tomorrow-night.yaml";

    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.callPackage "${inputs.private}/berkeley-mono-nerd-font/default.nix" { };
        name = "monospace";
      };

      serif = config.stylix.fonts.sansSerif;

      sizes = {
        applications = 10;
        terminal = 10;
        desktop = 10;
        popups = 10;
      };
    };

    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 10;
    };

    opacity = {
      terminal = 0.95;
    };

    targets.swaylock.useImage = false;
    targets.waybar.enable = false;
    targets.bemenu.enable = true;
    targets.rofi.enable = true;
    targets.nixvim = {
      enable = true;
      plugin = "base16-nvim";
      transparentBackground.main = true;
    };
    targets.swaync.enable = true;
  };

  wayland.windowManager.sway.config = {
    fonts.names = mkForce [ config.stylix.fonts.monospace.name ];
    colors = with config.lib.stylix.colors.withHashtag; mkForce {
      focused = rec {
        border = background;
        background = base0D;
        text = base00;
        indicator = base09;
        childBorder = border;
      };
      focusedInactive = rec{
        border = background;
        background = base05;
        text = base00;
        indicator = base0E;
        childBorder = border;
      };
      unfocused = rec {
        border = background;
        background = base03;
        text = base00;
        indicator = base0E;
        childBorder = border;
      };
      urgent = rec {
        border = background;
        background = base09;
        text = base00;
        indicator = base0E;
        childBorder = border;
      };
      placeholder = rec {
        border = background;
        background = base01;
        text = base00;
        indicator = base0E;
        childBorder = border;
      };
    };
  };
}
