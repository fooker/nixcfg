{ config, lib, pkgs, ... }:

with lib;
{
  options.boot = {
    device = mkOption {
      type = types.str;
      description = "Device to install GRUB on";
    };
  };

  config = mkIf (config.boot.preset == "grub") {
    boot.loader.grub = {
      enable = true;
      version = 2;
      device = config.boot.device;
    };
  };
}
