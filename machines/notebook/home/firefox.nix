{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    # enableAdobeFlash = true;
  };

  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
}
