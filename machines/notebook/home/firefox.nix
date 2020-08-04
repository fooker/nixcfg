{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;

    enableAdobeFlash = true;
  };

  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
}