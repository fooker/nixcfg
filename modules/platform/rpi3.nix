{ config, lib, ... }:

with lib;
{
  options.platform.rpi3 = mkEnableOption "Raspberry Pi 3";

  config = mkIf config.platform.rpi3 {
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
    ];

    boot.preset = "none";

    # TODO: This does not work right now - the firmware is installed into /boot instead of /boot/firmware
    # boot.loader = {
    #   grub.enable = false;
    #   generic-extlinux-compatible.enable = false;

    #   raspberryPi = {
    #     enable = true;
    #     version = 3;
    #     uboot.enable = true;
    #     firmwareConfig = ''
    #       start_x=1
    #       gpu_mem=128
    #     '';
    #   };
    # };

    # This requires to change /boot/firmware/config.txt manually
    boot.loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    services.journald.extraConfig = "Storage=volatile";

    documentation.enable = false;

    serial.unit = 1;
  };
}
