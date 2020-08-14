{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_5_7;
  boot.kernelParams = [
    "quiet"
    "i195.fastboot=1"
    "i915.enable_guc=3"
    "i915.enable_fbc=1"
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  
  boot.kernelModules = [ "kvm-intel" "i915" ];
  boot.extraModulePackages = [ ];

  hardware.enableAllFirmware = true;

  hardware.cpu.intel.updateMicrocode = true;

  # hardware.nvidiaOptimus.disable = true;
  
  hardware.nvidia = {
    modesetting.enable = true;
  
    prime = {
      offload.enable = true;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:45:0:0";
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  hardware.trackpoint = {
    enable = true;
    device = "TPPS/2 Elan TrackPoint";
    emulateWheel = true;
  };

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    zeroconf.discovery.enable = true;

    extraModules = [ pkgs.pulseaudio-modules-bt ];

    package = pkgs.pulseaudioFull;

    daemon.config = {
      avoid-resampling = "yes";
      alternate-sample-rate = 88200;
      default-fragment-size-msec = 125;
      default-fragments = 2;
      default-sample-channels = 2;
      default-sample-format = "s32le";
      default-sample-rate = 96000;
      enable-lfe-remixing = "no";
      realtime-scheduling = "yes";
      resample-method = "speex-float-10";
    };
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=root" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=home" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=log" "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ {
    device = "/dev/disk/by-uuid/8807b3fe-4359-4d80-b8a0-b85b98693859";
  } ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
