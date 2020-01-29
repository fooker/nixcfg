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

  services.journald.extraConfig = "Storage=volatile";

  documentation.enable = false;

  serial.unit = 1;
}
