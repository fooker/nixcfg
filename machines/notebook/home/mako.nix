{ pkgs, ... }:

{
  programs.mako = {
    enable = true;
    
    layer = "overlay";
    anchor = "top-right";

    font = "Hack 9.5";

    margin = "15";
    padding = "7";

    borderSize = 2;
    #borderColor = 
    borderRadius = 4;
  };
}