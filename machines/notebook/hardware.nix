{ config, pkgs, network, ... }:

{
  boot.kernelParams = [
    "quiet"
    "mitigations=off"

  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.plymouth.enable = true;

  hardware.enableAllFirmware = true;

  hardware.cpu.intel.updateMicrocode = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      libvdpau-va-gl
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiIntel
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

    settings.General.Experimental = true;
    settings.General.Testing = true;
  };

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
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
      ${toString network.devices."toiler".interfaces."priv".address.ipv4.address}
      ${toString network.devices."toiler".interfaces."priv".address.ipv6.address}
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
    device = "/dev/disk/by-uuid/4df4becf-494f-4839-94da-6255655733ab";
  }];

  services.hardware.bolt.enable = true;

  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        energy_performance_preference = "performance";
        platform_profile = "performance";
        turbo = "auto";
      };

      battery = {
        governor = "powersave";
        energy_performance_preference = "power";
        platform_profile = "low-power";
        turbo = "auto";
      };
    };
  };

  #powerManagement.cpuFreqGovernor = "performance";
  #services.tlp.enable = true;

  services.thinkfan = {
    enable = true;
  };
}
