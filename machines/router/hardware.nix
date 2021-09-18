{ lib, ... }:

with lib;

{
  boot.preset = "grub";
  boot.device = "/dev/sda";

  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  };

  nix.maxJobs = lib.mkDefault 2;
}
