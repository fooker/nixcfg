{ pkgs, sources, ... }:

{
  services.xserver = {
    enable = true;

    exportConfiguration = true;

    layout = "de";
    xkbModel = "pc105";
    xkbVariant = "nodeadkeys";

    videoDrivers = [ "modesetting" "nvidia" ];
    useGlamor = true;

    deviceSection = ''

    '';

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
        Option          "Accel Speed"   "-0.2"
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

    libinput = {
      enable = true;
    };

    displayManager = {
      lightdm = {
        enable = true;
        greeters.gtk = {
          enable = true;
        };
      };
    };

    # desktopManager.defaultSession = "xterm";
      
    # desktopManager.xterm.enable = true;
  };
}
