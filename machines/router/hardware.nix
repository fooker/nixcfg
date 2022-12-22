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

  nix.settings.max-jobs = lib.mkDefault 2;
}
