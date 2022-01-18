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
  ];

  boot.blacklistedKernelModules = [
    "nvidia"
    "nouveau"
  ];

  boot.kernelModules = [
    "vfio-pci"
  ];

  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1b06,10de:10ef
  '';
}
