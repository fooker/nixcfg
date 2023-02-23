{ pkgs, ... }:

{
  services.xserver = {
    enable = true;

    exportConfiguration = true;

    layout = "de";
    xkbModel = "pc105";
    xkbVariant = "nodeadkeys";

    videoDrivers = [
      "modesetting"
    ];

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
      ''
        Identifier      "Yowkees Keyball61"
        MatchVendor     "Yowkees"
        MatchProduct    "Keyball61"
        Driver          "libinput"
        Option          "ScrollButton"          "2"
        Option          "ScrollMethod"          "button"
      ''
      ''
        Identifier      "Bastard Keyboards Charybdis Nano (3x5) Splinky"
        MatchUSBID      "a8f8:1832"
        MatchIsPointer  "true"
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

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
