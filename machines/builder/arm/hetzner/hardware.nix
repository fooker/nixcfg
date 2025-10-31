{ lib, modulesPath, ... }:

with lib;

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  boot.initrd.kernelModules = [ "nvme" "xhci_pci" "virtio_pci" "usbhid" ];

  hardware.enableRedistributableFirmware = true;

  disko.devices = {
    disk."main" = {
      device = "/dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:1";
      type = "disk";
      imageSize = "30G";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "1G";
            label = "boot";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            label = "root";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };

  nix.settings.max-jobs = mkDefault 4;
}
