{ pkgs, ... }:

{
  services.redshift = {
    enable = true;
    #package = pkgs.redshift-wlr;
    package = pkgs.redshift;

    latitude = "49.8";
    longitude = "8.6";

    tray = true;
  };
}