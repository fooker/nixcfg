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
    "/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "ext4";
      encrypted = {
        enable = true;
        label = "data";
        blkDev = "/dev/disk/by-label/data-crypt";
        keyFile = "/mnt-root/${config.deployment.secrets."luks-data-key".destination}";
      };
    };
  };

  swapDevices = [{
    label = "swap";
  }];

  nix.maxJobs = lib.mkDefault 4;

  deployment.secrets = {
    "luks-data-key" = {
      source = "${path}/secrets/luks-data.key";
      destination = "/etc/secrets/luks-data.key";
      owner.user = "root";
      owner.group = "root";
    };
  };
}
