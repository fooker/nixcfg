{ pkgs, sources, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in {
  services.xserver = {
    enable = true;

    exportConfiguration = true;

    layout = "de";
    xkbModel = "pc105";
    xkbVariant = "nodeadkeys";

    # videoDrivers = [ "modesetting" ];
    videoDrivers = [ "nvidia" ];
    useGlamor = true;

    modules = with pkgs; [ 
      xorg.xf86inputlibinput
    ];

#    deviceSection = ''
#      Driver      "intel"
#      Option      "DRI"          "3"
##      Option      "VirtualHeads" "1"
#    '';

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
  #   (pkgs.callPackage (import ../../packages/ultraGrid.nix) {})
    glxinfo
    nvidia-offload
  ];
}
