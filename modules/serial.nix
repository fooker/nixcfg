{ config, lib, pkgs, ... }:

with lib;
{
  options.serial = {
    enable = mkOption {
        type = types.bool;
        default = false;
    };

    unit = mkOption {
      type = types.int;
      default = 0;
    };
  };

  config = mkIf config.serial.enable {
    boot.loader.grub.extraConfig = ''
      serial --unit=${toString config.serial.unit} --speed=115200
      terminal_output serial console
      terminal_input serial console
    '';

    boot.kernelParams = mkIf config.serial.enable [
      "console=ttyS${toString config.serial.unit},115200n8"
    ];
  };
}
