{ config, lib, pkgs, ... }:

with lib;
{
  config = mkIf (config.boot.preset == "grub") {
    boot.loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
  };
}
