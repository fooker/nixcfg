{ pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [ "en" ];
  };
}
