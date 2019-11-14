{ config, lib, pkgs, machineConfig, ... }:

with lib;
{
  options.serial = {
    enable = mkOption {
        type = types.bool;
        default = false;
    };
  };

  config = mkIf config.serial.enable {
    boot.loader.grub.extraConfig = ''
      serial --unit=0 --speed=115200
      terminal_output serial console
      terminal_input serial console
    '';

    boot.kernelParams = mkIf config.serial.enable [
      "console=ttyS0,115200n8"
    ];
  };
}
