{ lib, ... }:

with lib;

{
  hardware.enableRedistributableFirmware = true;

  boot.preset = "grub";
  boot.device = "/dev/sda";

  boot.initrd.availableKernelModules = [ "ata_piix" "vmw_pvscsi" "floppy" "sd_mod" "sr_mod" ];

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

  virtualisation.vmware.guest = {
    enable = true;
    headless = true;
  };
}
