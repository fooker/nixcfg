{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;

    location = "top";
    font = "Hack 9.5";
    separator = "solid";

    terminal = "${pkgs.ate}/bin/ate";

    theme = "glue_pro_blue";

    extraConfig = ''

    '';

    # package = with pkgs.unstable; rofi.override {
    #   plugins = [
    #     rofi-calc
    #     rofi-emoji
    #   ];
    # };
  };
}