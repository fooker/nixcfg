{ pkgs, lib, config, inputs, ... }:

with lib;

{
  imports = [
    inputs.stylix.homeManagerModules.stylix
  ];

  stylix = {
    image = pkgs.fetchurl {
      url = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/1280px-A_black_image.jpg";
      hash = "sha256-m5G/qK4LQUo0Y+UapX1l5DGHwE+1MiEBufY5hVz9RUA=";
    };

    base16Scheme = "${pkgs.base16-schemes}/share/themes/eighties.yaml";
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
        popups = 9;
      };
    };

    targets.swaylock.useImage = false;
    targets.waybar.enableRightBackColors = true;
  };

  wayland.windowManager.sway.config = {
    fonts.names = mkForce [ config.stylix.fonts.monospace.name ];
    colors = with config.lib.stylix.colors.withHashtag; mkForce {
      focused = rec {
        border = background;
        background = base0A;
        text = base00;
        indicator = base0D;
        childBorder = border;
      };
      focusedInactive = rec{
        border = background;
        background = base05;
        text = base00;
        indicator = base0B;
        childBorder = border;
      };
      unfocused = rec {
        border = background;
        background = base03;
        text = base05;
        indicator = base0B;
        childBorder = border;
      };
      urgent = rec {
        border = background;
        background = base09;
        text = base00;
        indicator = base0B;
        childBorder = border;
      };
      placeholder = rec {
        border = background;
        background = base01;
        text = base00;
        indicator = base0B;
        childBorder = border;
      };
    };
  };
}
