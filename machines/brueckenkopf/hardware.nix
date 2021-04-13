{ config, lib, modulesPath, path, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  hardware.enableRedistributableFirmware = true;

  boot.preset = "grub";
  boot.device = "/dev/vda";

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "ehci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.initrd.luks.devices = {
    "nixos" = {
      device = "/dev/disk/by-label/nixos-crypt";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      neededForBoot = true;
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  swapDevices = [ {
    label = "swap";
  } ];

  nix.maxJobs = lib.mkDefault 4;
}
