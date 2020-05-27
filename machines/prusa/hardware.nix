{ config, lib, pkgs, ... }:

{
  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  nix.maxJobs = lib.mkDefault 2;

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  boot.supportedFilesystems = lib.mkForce [ "vfat" ];
  boot.kernelParams = [
    "cma=64M"
    "console=tty0"
  ];

  # Extra kernel modules for RPi Camera 
  boot.kernelModules = [ "bcm2835_v4l2" "bcm2835_mmal_vchiq" "bcm2835_codec" ];
  boot.extraModprobeConfig = ''
    options bcm2835-v4l2 max_video_width=1920 max_video_height=1080 debug=2
  '';

  services.journald.extraConfig = "Storage=volatile";

  documentation.enable = false;

  serial.unit = 1;
}
