{ lib, pkgs, ... }:

with lib;

{
  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "ehci_pci" "nvme" "usb_storage" "sd_mod" "aesni_intel" "cryptd" ];
  boot.kernelModules = [ "kvm-amd" ];

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

  platform.cryptroot.enable = true;

  nix.settings.max-jobs = mkDefault 4;

  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.smartmontools}/bin/smartctl -s apm,32 -s standby,60 /dev/%k"
  '';
}
