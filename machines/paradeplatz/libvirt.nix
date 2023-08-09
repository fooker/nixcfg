{ pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;

    onShutdown = "shutdown";

    package = pkgs.unstable.libvirt;
    qemu.package = pkgs.unstable.qemu;
  };

  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "vga=0"
    "nofb"
    "nomodeset"
  ];

  boot.blacklistedKernelModules = [
    "nvidia"
    "nouveau"
  ];

  boot.kernelModules = [
    "vfio-pci" "vfio" "vfio-iommu-type1"
  ];

  boot.extraModprobeConfig = ''
    softdep drm pre: vfio-pci
    options vfio-pci ids=10de:1b06,10de:10ef
  '';

  security.polkit.enable = true;

  backup.paths = [
    "/var/lib/libvirt"
  ];
}
