{ pkgs, lib, inputs, ... }:

with lib;

{
  imports = [
    #"${inputs.nixos-hardware}/raspberry-pi/4"
  ];

  hardware.enableRedistributableFirmware = true;

  boot.preset = "none";
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # hardware = {
  #   raspberry-pi."4" = {
  #     apply-overlays-dtmerge.enable = true;
  #     fkms-3d.enable = true;
  #     #audio.enable = true;
  #   };

  #   deviceTree = {
  #     enable = true;
  #     #filter = mkForce "*-rpi-4-*.dtb";
  #   };
  # };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

  boot.initrd.availableKernelModules = [
    "usbhid"
    "usb_storage"
    "vc4"
    "pcie_brcmstb" # required for the pcie bus to work
    "reset-raspberrypi" # required for vl805 firmware to load
  ];

  hardware.opengl = {
    enable = true;
    extraPackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [ "nofail" "noauto" ];
    };
  };
}
