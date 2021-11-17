{ config, pkgs, ... }:

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
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    pulse = {
      enable = true;
    };

    media-session = {
      enable = true;
    };
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  services.udev.packages = with pkgs; [
    stlink
    saleae-logic-2
  ];

  hardware.sane.enable = true;

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
