{ config, lib, pkgs, ... }:

{
  platform.rpi3 = true;

  # Extra kernel modules for RPi Camera 
  boot.kernelModules = [ "bcm2835_v4l2" "bcm2835_mmal_vchiq" "bcm2835_codec" ];
  boot.extraModprobeConfig = ''
    options bcm2835-v4l2 max_video_width=1920 max_video_height=1080 debug=2
  '';

  # Add missing firmware file RPi Camera
  hardware.firmware = [
    (pkgs.stdenv.mkDerivation {
      name = "broadcom-rpi3bplus-extra";

      src = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/b518de4/brcm/brcmfmac43455-sdio.txt";
        sha256 = "0r4bvwkm3fx60bbpwd83zbjganjnffiq1jkaj0h20bwdj9ysawg9";
      };

      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out/lib/firmware/brcm
        cp $src $out/lib/firmware/brcm/brcmfmac43455-sdio.txt
      '';
    })
  ];
}
