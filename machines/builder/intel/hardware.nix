{ lib, modulesPath, ... }:

with lib;

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  swapDevices = [{
    label = "swap";
  }];

  nix.settings.max-jobs = mkDefault 4;
}
