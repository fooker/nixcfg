{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
}
