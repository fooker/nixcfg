{ lib, pkgs, ... }:

{
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ "i915" ];

  # Disable IR driver to silence funky kernel messages
  boot.blacklistedKernelModules = [ "ite_cir" ];

  boot.kernelModules = [ "kvm-intel" ];

  disko.devices = {
    disk."main" = {
      device = "/dev/disk/by-id/nvme-nvme.1e4b-4153424a3533343130333031383632-4163657220535344204e3530303020325442-00000001";
      type = "disk";
      imageSize = "30G";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "100M";
            label = "boot";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            size = "8G";
            label = "swap";
            content = {
              type = "swap";
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

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  nix.settings.max-jobs = lib.mkDefault 4;

  powerManagement.cpuFreqGovernor = "powersave";
}
