{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./grub.nix
    ./systemd.nix
    ./extlinux.nix
  ];

  options.boot = {
    type = mkOption {
        type = types.enum [ "grub" "systemd" "extlinux" ];
        default = "systemd";
    };
  };

  config = {
    boot.tmpOnTmpfs = true;

    # Reboot on panic
    boot.kernelParams = [ "panic=1" "boot.panic_on_fail" ];
  };
}
