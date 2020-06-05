{ config, lib, pkgs, ... }:

{
  platform.rpi3 = true;

  fileSystems = {
    "/mnt" = {
      device = "/dev/disk/by-label/DATA";
      fsType = "ext4";
      options = [ "nouser" "noatime" "data=writeback" ];
    };
  };
}
