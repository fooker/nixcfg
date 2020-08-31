{ pkgs, sources, ... }:

{
  services.xserver = {
    enable = true;

    exportConfiguration = true;

    layout = "de";
    xkbModel = "pc105";
    xkbVariant = "nodeadkeys";

    videoDrivers = [
      "displaylink"
      "modesetting"
    ];
    useGlamor = true;

    modules = with pkgs; [ 
      xorg.xf86inputlibinput
    ];

    inputClassSections = [
      ''
        Identifier      "Touchpad"
        MatchIsTouchpad "on"
        Option          "Ignore" "on"
      ''
      ''
        Identifier      "Trackpoint"
        MatchProduct    "TPPS/2 IBM TrackPoint"
        Driver          "libinput"
        Option          "Accel Speed"   "-0.4"
        Option          "Accel Profile" "adaptive"
      ''
      ''
        Identifier      "Logitech M570"
        MatchVendor     "Logitech"
        MatchProduct    "M570"
        Driver          "libinput"
        Option          "ScrollButton"          "2"
        Option          "ScrollMethod"          "button"
      ''
      ''
        Identifier      "Logitech MX Ergo"
        MatchVendor     "Logitech"
        MatchProduct    "MX Ergo"
        Driver          "libinput"
        Option          "ScrollButton"          "2"
        Option          "ScrollMethod"          "button"
      ''
    ];

    updateDbusEnvironment = true;

    displayManager.startx.enable = true;

    verbose = 7;
  };

  services.udev.packages = [ pkgs.libinput.out ];

  environment.systemPackages = with pkgs; [
    glxinfo
  ];
}
