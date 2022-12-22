{ lib, ... }:

with lib;

{
  hardware.enableRedistributableFirmware = true;

  boot.preset = "grub";
  boot.device = "/dev/sda";

  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "floppy" "sd_mod" "sr_mod" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      neededForBoot = true;
    };
  };

  swapDevices = [{
    label = "swap";
  }];

  nix.settings.max-jobs = mkDefault 4;

  virtualisation.vmware.guest = {
    enable = true;
    headless = true;
  };
}
