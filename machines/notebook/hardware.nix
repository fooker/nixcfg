{ config, pkgs, network, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_5_10;

  boot.kernelParams = [
    "quiet"
    "i195.fastboot=1"
    "i915.enable_guc=2"
    "i915.enable_fbc=1"
    "mitigations=off"

    # See https://iam.tj/prototype/enhancements/Windows-acpi_osi.html
    "acpi_osi=!"
    "acpi_osi=\"Windows 2015\""
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];

  boot.kernelModules = [ "kvm-intel" "i915" "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  hardware.enableAllFirmware = true;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.nvidiaOptimus.disable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
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
    hsphfpd.enable = true;
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

  services.udev.packages = with pkgs; [
    stlink
    saleae-logic-2
    qmk-udev-rules
  ];

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    netConf = ''
      ${toString network.devices."scanner".interfaces."priv".address.ipv4.address}
      ${toString network.devices."scanner".interfaces."priv".address.ipv6.address}
    '';
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

  swapDevices = [{
    device = "/dev/disk/by-uuid/8807b3fe-4359-4d80-b8a0-b85b98693859";
  }];

  services.hardware.bolt.enable = true;

  powerManagement.cpuFreqGovernor = "performance";

  services.tlp = {
    enable = true;
    settings = {
      "CPU_SCALING_GOVERNOR_ON_AC" = "powersave";
      "CPU_SCALING_GOVERNOR_ON_BAT" = "powersave";

      "START_CHARGE_THRESH_BAT0" = 60;
      "STOP_CHARGE_THRESH_BAT0" = 100;

      "WIFI_PWR_ON_AC" = false;
      "WIFI_PWR_ON_BAT" = false;
    };
  };

  services.throttled = {
    enable = true;
  };
}
