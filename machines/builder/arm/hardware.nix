{ lib, modulesPath, ... }:

with lib;

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  boot.initrd.kernelModules = [ "nvme" "xhci_pci" "virtio_pci" "usbhid" ];

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

  nix.maxJobs = mkDefault 4;
}
