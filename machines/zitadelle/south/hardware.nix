{ config, lib, modulesPath, path, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  hardware.enableRedistributableFirmware = true;

  boot.preset = "grub";
  boot.device = "/dev/sda";

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "ehci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.initrd.luks.devices = {
    "nixos" = {
      device = "/dev/disk/by-label/nixos-crypt";
      allowDiscards = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "noatime" "discard" ];
      neededForBoot = true;
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
    "/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "btrfs";
      options = [ "noatime" "discard" ];
      encrypted = {
        enable = true;
        label = "data";
        blkDev = "/dev/disk/by-label/data-crypt";
        keyFile = "/mnt-root/${config.deployment.keys."luks-data-key".path}";
      };
    };
  };

  swapDevices = [{
    label = "swap";
  }];

  nix.maxJobs = lib.mkDefault 4;

  deployment.keys = {
    "luks-data-key" = {
      keyFile = "${path}/secrets/luks-data.key";
      destDir = "/etc/secrets";
      user = "root";
      group = "root";
    };
  };
}
