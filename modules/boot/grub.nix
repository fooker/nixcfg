{ config, lib, ... }:

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
      inherit (config.boot) device;
    };
  };
}
