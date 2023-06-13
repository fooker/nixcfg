{ lib, modulesPath, ... }:

with lib;

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  hardware.enableRedistributableFirmware = true;

  boot.preset = "grub";
  boot.device = "/dev/sda";

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  };

  swapDevices = [{
    label = "swap";
  }];

  nix.settings.max-jobs = mkDefault 4;
}
