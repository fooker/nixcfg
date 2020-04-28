{ config, lib, pkgs, ... }:

with lib;
{
  config = mkIf (config.boot.type == "grub") {
    boot.loader = {
      grub.enable = true;
      grub.version = 2;
      grub.device = "/dev/sda";
    };
  };
}
