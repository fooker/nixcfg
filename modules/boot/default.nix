{ lib, ... }:

with lib;
{
  imports = [
    ./grub.nix
    ./systemd.nix
  ];

  options.boot = {
    preset = mkOption {
      type = types.enum [ "grub" "systemd" "none" ];
      default = "systemd";
    };
  };

  config = {
    boot.tmpOnTmpfs = true;

    # Reboot on panic
    boot.kernelParams = [ "panic=1" "boot.panic_on_fail" ];
  };
}
