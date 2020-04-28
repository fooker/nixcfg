{ config, lib, pkgs, ... }:

with lib;
{
  config = mkIf (config.boot.type == "extlinux") {
    boot.loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
}
