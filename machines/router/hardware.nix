{ config, lib, pkgs, ... }:

{
  boot.preset = "grub";

  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  };

  swapDevices = [ {
    label = "swap";
  } ];

  nix.maxJobs = lib.mkDefault 2;


}
