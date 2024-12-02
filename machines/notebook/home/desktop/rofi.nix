{ pkgs, lib, ... }:

with lib;

{
  programs.rofi = {
    enable = true;

    cycle = true;
    location = "center";

    plugins = with pkgs; [
      rofi-emoji
      rofi-rbw-wayland
    ];

    package = pkgs.rofi-wayland;

    theme = {
      window = {
        transparency = "real";

        padding = 10;

        border = 2;
        border-radius = 2;
        border-color = "@unikitty-dark";
      };
    };
  };
}

